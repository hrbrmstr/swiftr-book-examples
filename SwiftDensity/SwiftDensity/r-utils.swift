import Foundation

/// Rf_protect wrapper since the PROTECT macro is unusable from Swift
///
/// Defined in case muscle memory forgets to use RPROTECT from the C bridge
let PROTECT = Rf_protect

/// Rf_unprotect wrapper since the UNPROTECT macro is unusable from Swift
///
/// Defined in case muscle memory forgets to use RUNPROTECT from the C bridge
let UNPROTECT = Rf_unprotect

/// R-related exceptions
enum RError: Error {
  case tryEvalError(String) // we only have one R error exception type for the moment.
}

// MARK: Swift helper to varName <- value

/// Define a global object within R from the passed in SEXP
///
/// - Parameters:
///   - varName: name of the object
///   - value: SEXP value to assign the object
func defineGlobal(_ varName: String, _ value: SEXP) {
  Rf_defineVar(Rf_install(varName), value, R_GlobalEnv)
}

// MARK: Swift helper to require(package)

/// Equivalent of R's library(pkg)
///
/// - Parameter pkg: R package to load
/// - Throws: An `RError.tryEvalError`
func require(_ pkg: String) throws -> Bool {
  
  var rErr: CInt = 0 // holds our error return value from evaluation
  
  let requireCall: SEXP = RPROTECT(Rf_allocVector(SEXPTYPE(LANGSXP), 3+1))!
  defer { RUNPROTECT(1) }
  SETCAR(requireCall, Rf_install("require"))
  
  var reqParams: SEXP = CDR(requireCall);
  SETCAR(reqParams,  RPROTECT(Rf_mkString(pkg)))
  defer { RUNPROTECT(1) }
  SET_TAG(reqParams, Rf_install("package"))
  
  reqParams = CDR(reqParams)
  SETCAR(reqParams, RPROTECT(Rf_ScalarLogical(1)))
  defer { RUNPROTECT(1) }
  SET_TAG(reqParams, Rf_install("warn.conflicts"))
  
  reqParams = CDR(reqParams)
  SETCAR(reqParams, RPROTECT(Rf_ScalarLogical(1)))
  defer { RUNPROTECT(1) }
  SET_TAG(reqParams, Rf_install("quietly"))
  
  // requireCall is PROTECTed above but Rf_install() may allocate which could kill it so make sure it is safe
  let suppressWarningsCall = RPROTECT(Rf_lang2(Rf_install("suppressWarnings"), requireCall))
  defer { RUNPROTECT(1) }
  
  let suppressPackageStartupMessagesCall = RPROTECT(Rf_lang2(Rf_install("suppressPackageStartupMessages"), suppressWarningsCall))
  defer { RUNPROTECT(1) }
  
  let res: SEXP = RPROTECT(R_tryEvalSilent(suppressPackageStartupMessagesCall, R_GlobalEnv, &rErr))!
  defer { RUNPROTECT(1) }

  if (rErr == 0) {
    if (SEXPTYPE(TYPEOF(res)) == LGLSXP) {
      return(Rf_asLogical(res) == 1)
    } else {
      throw RError.tryEvalError(
        "R evaluation error attempting to load. Expected TRUE/FALSE, but found '\(String(cString: Rf_type2char(SEXPTYPE(TYPEOF(res)))))"
      )
    }
  } else {
    throw RError.tryEvalError("R evaluation error attempting to load \(pkg): \(String(cString: R_curErrorBuf()))")
  }
  
}

// MARK: Parse a string of R code and return the parse status

/// Parse a string of R code and return the parse status
///
/// - Parameters
///   - string: The R code to parse
/// - Returns: ParseStatus enum value
func parseStatus(_ string: String) -> ParseStatus {

  let vectorToParse = [ string ].protectedSEXP
  defer { RUNPROTECT(1) }

  var status: ParseStatus = PARSE_OK
  let _ = RPROTECT(R_ParseVector(vectorToParse, -1, &status, R_NilValue))
  RUNPROTECT(1)

  return(status)

}

/// Parse an R script/code that is stored in a string
///
/// - Parameters
///   - string: The R code to parse
///
/// The returned SEXP will NOT be protected
func parseRScript(_ string: String) -> SEXP {
  
  let vectorToParse = [ string ].protectedSEXP
  defer { RUNPROTECT(1) }
  
  var status: ParseStatus = PARSE_OK
  let res = RPROTECT(R_ParseVector(vectorToParse, -1, &status, R_NilValue))
  RUNPROTECT(1)
  
  return((status == PARSE_OK) ? res! : R_NilValue)
  
}

/// Evaluate parsed R code
///
/// - Parameters
///   - parsedSEXP: The parsed R code to evaluate
///
/// Each SEXP element of the returned Swift array of SEXPs WILL BE protected.
///
/// - Important: The caller will be expected to call the SEXP Array `UNPROTECT()` method.
func evalSEXP(_ parsedSEXP: SEXP) -> [SEXP] {
  
  var rErr: CInt = 0
  var res: [SEXP] = [SEXP]()
  
  res.reserveCapacity(Int(Rf_length(parsedSEXP)))
  
  for idx in 0..<Rf_length(parsedSEXP) {
    let evaluated = R_tryEvalSilent(VECTOR_ELT(parsedSEXP.protectedSEXP, R_xlen_t(idx)), R_GlobalEnv, &rErr)
    defer { RUNPROTECT(1) }
    if (rErr != 0) {
      res.append(R_NilValue)
      R_ShowMessage("Eval failure: \(String(cString: R_curErrorBuf()))")
    } else {
      res.append(RPROTECT(evaluated))
    }
  }
  
  return(res)
  
}

// MARK: This will use R_ParseVector + R_tryEvalSilent and return an array of resultant SEXPs

/// Parse and evaluate (quietly) R code stored in a Swift String Array.
///
/// - Parameters
///   - vec: an Swift array of Strings containing R code
///
/// Each SEXP element of the returned Swift array of SEXPs WILL BE protected.
///
/// - Important: The caller will be expected to call the SEXP Array `UNPROTECT()` method.
func safeSilentEvalParse(_ vec: [String]) -> [SEXP] {

  let vectorToParse = vec.protectedSEXP
  defer { RUNPROTECT(1)}
  var status: ParseStatus = PARSE_OK
  let parsed = RPROTECT(R_ParseVector(vectorToParse, -1, &status, R_NilValue))
  defer { RUNPROTECT(1)}

  if (status == PARSE_OK) {
    var rErr: CInt = 0
    var res: [SEXP] = [SEXP]()
    res.reserveCapacity(Int(Rf_length(parsed)))
    for idx in 0..<Rf_length(parsed) {
      let evaluated = R_tryEvalSilent(VECTOR_ELT(parsed, R_xlen_t(idx)), R_GlobalEnv, &rErr)
      if (rErr != 0) {
        res.append(R_NilValue)
        R_ShowMessage("Eval failure: \(String(cString: R_curErrorBuf()))")
      } else {
        res.append(RPROTECT(evaluated))
      }
    }
    return(res)
  } else {
    R_ShowMessage("Parse failure \(status.rawValue)")
    return([R_NilValue])
  }
  
}

// MARK: This is just like safeSilentEvalParse() except it doesn't force the caller to build an array

/// Parse and evaluate (quietly) R code stored in a Swift String.
///
/// - Parameters
///   - string: a Swift String of R code
///
/// Each SEXP element of the returned Swift array of SEXPs WILL BE protected.
/// 
/// - Important: The caller will be expected to call the SEXP Array `UNPROTECT()` method.
func safeSilentEvalParseString(_ string: String, showMessage: Bool = false) -> [SEXP] {
    
  let vectorToParse = [ string ].protectedSEXP
  defer { RUNPROTECT(1) }
  var status: ParseStatus = PARSE_OK
  let parsed = RPROTECT(R_ParseVector(vectorToParse, -1, &status, R_NilValue))
  defer { RUNPROTECT(1) }
  
  if (status == PARSE_OK) {
    var rErr: CInt = 0
    var res: [SEXP] = [SEXP]()
    res.reserveCapacity(Int(Rf_length(parsed)))
    for idx in 0..<Rf_length(parsed) {
      let evaluated = R_tryEvalSilent(VECTOR_ELT(parsed, R_xlen_t(idx)), R_GlobalEnv, &rErr)
      if (rErr != 0) {
        res.append(R_NilValue)
        if (showMessage) { R_ShowMessage("Eval failure: \(String(cString: R_curErrorBuf()))") }
      } else {
        res.append(RPROTECT(evaluated))
      }
    }
    return(res)
  } else {
    if (showMessage) { R_ShowMessage("Parse failure \(status.rawValue)") }
    return([R_NilValue])
  }
  
}

// MARK: Swift wrappers for Rf_lang…

/// All of the Rlang#() functions call Rf_lang# and are evalueted
///
/// - Parameters
///   - call: a SEXP call
///   - (params-if-any): SEXP parameters (if any)
///   - env: R environment to use (defaults to Global)
///
/// - Important: The returned SEXP is NOT protected
func Rlang1(_ call: SEXP, env: SEXP = R_GlobalEnv) throws -> SEXP {
  
  var err: CInt = 0
  
  let call_ƒ = RPROTECT(Rf_lang1(call.protectedSEXP))
  defer { RUNPROTECT(2) }
  
  let res: SEXP = RPROTECT(R_tryEvalSilent(call_ƒ, env, &err)) ?? R_NilValue
  defer { RUNPROTECT(1) }
  
  if (err != 0) {
    throw RError.tryEvalError(String(cString: R_curErrorBuf()))
  }
  
  return(res)
  
}

/// - SeeAlso: Rlang1
func Rlang2(_ call: SEXP, x: SEXP, env: SEXP = R_GlobalEnv) throws -> SEXP {
  
  var err: CInt = 0
  
  let call_ƒ = RPROTECT(
    Rf_lang2(
      call.protectedSEXP,
      x.protectedSEXP
    )
  )
  defer { RUNPROTECT(3) }
  
  let res: SEXP = RPROTECT(R_tryEvalSilent(call_ƒ, env, &err)) ?? R_NilValue
  defer { RUNPROTECT(1) }

  if (err != 0) {
    throw RError.tryEvalError(String(cString: R_curErrorBuf()))
  }
  
  return(res)
  
}

/// - SeeAlso: Rlang1
func Rlang3(_ call: SEXP, x: SEXP, y: SEXP, env: SEXP = R_GlobalEnv) throws -> SEXP {
  
  var err: CInt = 0
  
  let call_ƒ = RPROTECT(
    Rf_lang3(
      call.protectedSEXP,
      x.protectedSEXP,
      y.protectedSEXP
    )
  )
  defer { RUNPROTECT(4) }
  
  let res: SEXP = RPROTECT(R_tryEvalSilent(call_ƒ, env, &err)) ?? R_NilValue
  defer { RUNPROTECT(1) }
  
  if (err != 0) {
    throw RError.tryEvalError(String(cString: R_curErrorBuf()))
  }
  
  return(res)
  
}

/// - SeeAlso: Rlang1
func Rlang4(_ call: SEXP, x: SEXP, y: SEXP, z: SEXP, env: SEXP = R_GlobalEnv) throws -> SEXP {
  
  var err: CInt = 0
  
  let call_ƒ = RPROTECT(
    Rf_lang4(
      call.protectedSEXP,
      x.protectedSEXP,
      y.protectedSEXP,
      z.protectedSEXP
    )
  )
  defer { RUNPROTECT(5) }
  
  let res: SEXP = RPROTECT(R_tryEvalSilent(call_ƒ, env, &err)) ?? R_NilValue
  defer { RUNPROTECT(1) }
  
  if (err != 0) {
    throw RError.tryEvalError(String(cString: R_curErrorBuf()))
  }
  
  return(res)
  
}

/// - SeeAlso: Rlang1
func Rlang5(_ call: SEXP, x: SEXP, y: SEXP, z: SEXP, a: SEXP, env: SEXP = R_GlobalEnv) throws -> SEXP {
  
  var err: CInt = 0
  
  let call_ƒ = RPROTECT(
    Rf_lang5(
      call.protectedSEXP,
      x.protectedSEXP,
      y.protectedSEXP,
      z.protectedSEXP,
      a.protectedSEXP
    )
  )
  defer { RUNPROTECT(6) }
  
  let res: SEXP = RPROTECT(R_tryEvalSilent(call_ƒ, env, &err)) ?? R_NilValue
  defer { RUNPROTECT(1) }
  
  if (err != 0) {
    throw RError.tryEvalError(String(cString: R_curErrorBuf()))
  }
  
  return(res)
  
}

/// - SeeAlso: Rlang1
func Rlang6(_ call: SEXP, x: SEXP, y: SEXP, z: SEXP, a: SEXP, b: SEXP, env: SEXP = R_GlobalEnv) throws -> SEXP {
  
  var err: CInt = 0
  
  let call_ƒ = RPROTECT(
    Rf_lang6(
      call.protectedSEXP,
      x.protectedSEXP,
      y.protectedSEXP,
      z.protectedSEXP,
      a.protectedSEXP,
      b.protectedSEXP
    )
  )
  defer { RUNPROTECT(7) }
  
  let res: SEXP = RPROTECT(R_tryEvalSilent(call_ƒ, env, &err)) ?? R_NilValue
  defer { RUNPROTECT(1) }
  
  if (err != 0) {
    throw RError.tryEvalError(String(cString: R_curErrorBuf()))
  }
  
  return(res)
  
}

import Foundation

let PROTECT = Rf_protect
let UNPROTECT = Rf_unprotect

// we only have one R error exception type for the moment.
enum RError: Error {
  case tryEvalError(String)
}

// Swift helper to require(package)
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
  let suppressWarningsCall = RPROTECT(Rf_lang2(Rf_install("suppressWarnings"), RPROTECT(requireCall)))
  defer { RUNPROTECT(2) }
  
  let res: SEXP = RPROTECT(R_tryEvalSilent(suppressWarningsCall, R_GlobalEnv, &rErr))!
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

func safeSilentEvalParseString(_ string: String, showMessage: Bool = false) -> [SEXP] {
  
  let vectorToParse = [ string ].protectedSEXP
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

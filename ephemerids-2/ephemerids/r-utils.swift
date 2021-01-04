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


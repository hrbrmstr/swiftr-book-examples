import Foundation

extension String {
  init?(_ sexp: SEXP) {
    if ((sexp != R_NilValue) && (Rf_length(sexp) == 1)) {
      switch (TYPEOF(sexp)) {
      case STRSXP: self = String(cString: CHAR_Rf_asChar(sexp))
      default: return(nil)
      }
    } else {
      return(nil)
    }
  }
  var SEXP: SEXP { return(Rf_mkString(self)) }
  var protectedSEXP: SEXP { return(RPROTECT(Rf_mkString(self))) }
}

extension Int {
  init?(_ sexp: SEXP) {
    if ((sexp != R_NilValue) && (Rf_length(sexp) == 1)) {
      switch (TYPEOF(sexp)) {
      case INTSXP: self = Int(Rf_asInteger(sexp))
      default: return(nil)
      }
    } else {
      return(nil)
    }
  }
  var SEXP: SEXP { return(Rf_ScalarInteger(CInt(self))) }
  var protectedSEXP: SEXP { return(RPROTECT(Rf_ScalarInteger(CInt(self)))) }
}

extension Double {
  
  init?(_ sexp: SEXP) {
  
    if ((sexp != R_NilValue) && (Rf_length(sexp) == 1)) {
      switch (TYPEOF(sexp)) {
      case REALSXP: self = Rf_asReal(sexp)
      case INTSXP: self = Double(Int(sexp)!) // a tad more dangerous
      case STRSXP: self = Double(String(sexp)!)! // a tad more dangerous
      default: return(nil)
      }
    } else {
      return(nil)
    }
    
  }
  
  var SEXP: SEXP { return(Rf_ScalarReal(self)) }
  var protectedSEXP: SEXP { return(RPROTECT(Rf_ScalarReal(self))) }
}



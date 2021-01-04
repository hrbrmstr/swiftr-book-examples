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
  var protectedSEXP: SEXP {
    return(SEXP.protectedSEXP)
  }
}

extension Bool {
  init?(_ sexp: SEXP) {
    if ((sexp != R_NilValue) && (Rf_length(sexp) == 1)) {
      switch (TYPEOF(sexp)) {
      case LGLSXP: self = (Rf_asLogical(sexp) == 1)
      default: return(nil)
      }
    } else {
      return(nil)
    }
  }
  var SEXP: SEXP { return(Rf_ScalarLogical(self ? 1 : 0)) }
  var protectedSEXP: SEXP {
    return(SEXP.protectedSEXP)
  }
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
  var protectedSEXP: SEXP {
    return(SEXP.protectedSEXP)
  }
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
  var protectedSEXP: SEXP {
    return(SEXP.protectedSEXP)
  }
}

extension Array where Element == Bool {
  init?(_ sexp: SEXP) {
    if (sexp.isLOGICAL) {
      var val : [Bool] = [Bool]()
      val.reserveCapacity(Int(sexp.count))
      let LOGICALVEC = LOGICAL(sexp)
      for idx in 0..<sexp.count {
        val.append(LOGICALVEC![Int(idx)] == 1)
      }
      self = val
    } else {
      return(nil)
    }
  }
  var SEXP: SEXP? {
    let logicalVec = RPROTECT(Rf_allocVector(SEXPTYPE(LGLSXP), count))
    defer { RUNPROTECT(1) }
    let LOGICALVEC = LOGICAL(logicalVec)
    for (idx, elem) in enumerated() { LOGICALVEC![idx] = (elem ? 1 : 0) }
    return(logicalVec)
  }
  var protectedSEXP: SEXP? {
    return(SEXP?.protectedSEXP)
  }
}

extension Array where Element == Double {
  init?(_ sexp: SEXP) {
    if (sexp.isREAL) {
      var val : [Double] = [Double]()
      val.reserveCapacity(Int(sexp.count))
      let REALVEC = REAL(sexp)
      for idx in 0..<sexp.count {
        val.append(Double(REALVEC![Int(idx)]))
      }
      self = val
    } else {
      return(nil)
    }
  }
  var SEXP: SEXP? {
    let realVec = RPROTECT(Rf_allocVector(SEXPTYPE(REALSXP), count))
    defer { RUNPROTECT(1) }
    let REALVEC =  REAL(realVec)
    for (idx, elem) in enumerated() { REALVEC![idx] = elem }
    return(realVec)
  }
  var protectedSEXP: SEXP? {
    return(SEXP?.protectedSEXP)
  }
}

extension Array where Element == Int {
  init?(_ sexp: SEXP) {
    if (sexp.isINTEGER) {
      var val : [Int] = [Int]()
      val.reserveCapacity(Int(sexp.count))
      let INTEGERVEC = INTEGER(sexp)
      for idx in 0..<sexp.count {
        val.append(Int(INTEGERVEC![Int(idx)]))
      }
      self = val
    } else {
      return(nil)
    }
  }
  var SEXP: SEXP? {
    let intVec = RPROTECT(Rf_allocVector(SEXPTYPE(INTSXP), count))
    defer { RUNPROTECT(1) }
    let INTEGERVEC = INTEGER(intVec)
    for (idx, elem) in enumerated() { INTEGERVEC![idx] = CInt(elem) }
    return(intVec)
  }
  var protectedSEXP: SEXP? {
    return(SEXP?.protectedSEXP)
  }
}

extension Array where Element == String {
  init?(_ sexp: SEXP) {
    if (sexp.isSTRING) {
      var val : [String] = [String]()
      val.reserveCapacity(Int(sexp.count))
      for idx in 0..<sexp.count {
        val.append(String(cString: RVecElToCstr(sexp, R_xlen_t(idx))))
      }
      self = val
    } else {
      return(nil)
    }
  }
  var SEXP: SEXP? {
    let charVec = RPROTECT(Rf_allocVector(SEXPTYPE(STRSXP), count))
    defer { RUNPROTECT(1) }
    for (idx, elem) in enumerated() { SET_STRING_ELT(charVec, idx, Rf_mkChar(elem)) }
    return(charVec)
  }
  var protectedSEXP: SEXP? {
    return(SEXP?.protectedSEXP)
  }
}

extension Array where Element == SEXP {
  func UNPROTECT() {
    RUNPROTECT(CInt(filter { $0 != R_NilValue }.count))
  }
}

extension SEXP {
  var length: R_len_t {
    Rf_length(self)
  }
  var count: R_len_t {
    Rf_length(self)
  }
  var typeOf: SEXPTYPE {
    SEXPTYPE(TYPEOF(self))
  }
  var type: String {
    String(cString: Rf_type2char(SEXPTYPE(TYPEOF(self))))
  }
  var isLOGICAL: Bool {
    self.typeOf == LGLSXP
  }
  var isREAL: Bool {
    self.typeOf == REALSXP
  }
  var isINTEGER: Bool {
    self.typeOf == INTSXP
  }
  var isSTRING: Bool {
    self.typeOf == STRSXP
  }
  var isLIST: Bool {
    self.typeOf == VECSXP
  }
  var isNULL: Bool {
    self == R_NilValue
  }
  var anyNA: Bool? {
    do {
      return(Bool(try Rlang2(Rf_install("anyNA"), x:self)))
    } catch {
      return(nil)
    }
  }
  var mode: String? {
    do {
      return(try String(Rlang2(R_ModeSymbol, x: self)))
    } catch {
      return(nil)
    }
  }
  var namesAttrib: [String]? {
    [String](Rf_getAttrib(self, R_NamesSymbol))
  }
  var classAttrib: [String]? {
    [String](Rf_getAttrib(self, R_ClassSymbol))
  }
  var protectedSEXP: SEXP {
    RPROTECT(self)
  }
}

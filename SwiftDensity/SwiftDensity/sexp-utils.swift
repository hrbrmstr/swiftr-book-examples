import Foundation

extension Data {
  
  /// Create a Data from an RAWSXP
  public init?(_ sexp: SEXP) {
    if (sexp != R_NilValue) {
      switch (TYPEOF(sexp)) {
      case RAWSXP: self = Data(bytes: RAW(sexp), count: Int(sexp.count))
      default: return(nil)
      }
    } else {
      return(nil)
    }
  }
  
}

extension String {
  
  /// Create a String from an STRSXP
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
  
  /// Provide a SEXP representation (STRSXP) of this String
  var SEXP: SEXP { return(Rf_mkString(self)) }
  
  /// Provide a protected SEXP representation of this String's SEXP
  /// - Important: the caller is responsible for UNPROTECTing it
  var protectedSEXP: SEXP {
    return(SEXP.protectedSEXP)
  }
}

extension Bool {
  
  /// Create a Bool from an LGLSXP
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
  
  /// Provide a SEXP representation (LGLSXP) of this Bool
  var SEXP: SEXP { return(Rf_ScalarLogical(self ? 1 : 0)) }
  
  /// Provide a protected SEXP representation of this Bool's SEXP
  /// - Important: the caller is responsible for UNPROTECTing it
  var protectedSEXP: SEXP {
    return(SEXP.protectedSEXP)
  }
}

extension Int {
  
  /// Create an Int from an INTSXP
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
  
  /// Provide a SEXP representation (INTSXP) of this Int
  var SEXP: SEXP { return(Rf_ScalarInteger(CInt(self))) }
  
  /// Provide a protected SEXP representation of this Int's SEXP
  /// - Important: the caller is responsible for UNPROTECTing it
  var protectedSEXP: SEXP {
    return(SEXP.protectedSEXP)
  }
}

extension Double {
  
  /// Create a Double from a REALXSP, INTSXP, or STRSXP
  init?(_ sexp: SEXP) {
  
    if ((sexp != R_NilValue) && (Rf_length(sexp) == 1)) {
      switch (TYPEOF(sexp)) {
      case REALSXP: self = Rf_asReal(sexp)
      case INTSXP: self = Double(Int(sexp)!) // a tad more dangerous
      case STRSXP: self = Double(String(sexp)!)! // a tad, tad more dangerous
      default: return(nil)
      }
    } else {
      return(nil)
    }
    
  }

  /// Provide a SEXP representation (REALSXP) of this Double
  var SEXP: SEXP { return(Rf_ScalarReal(self)) }
  
  /// Provide a protected SEXP representation of this Double's SEXP
  /// - Important: the caller is responsible for UNPROTECTing it
  var protectedSEXP: SEXP {
    return(SEXP.protectedSEXP)
  }
  
}

extension Array where Element == Bool {
  
  /// Create a Swift Bool Array from an R logical vector
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
  
  /// Provide a SEXP representation (logical vector) of this Bool Array
  var SEXP: SEXP? {
    let logicalVec = RPROTECT(Rf_allocVector(SEXPTYPE(LGLSXP), count))
    defer { RUNPROTECT(1) }
    let LOGICALVEC = LOGICAL(logicalVec)
    for (idx, elem) in enumerated() { LOGICALVEC![idx] = (elem ? 1 : 0) }
    return(logicalVec)
  }
  
  /// Provide a protected SEXP representation (logical vector) of this Bool Array
  /// - Important: the caller is responsible for UNPROTECTing it
  var protectedSEXP: SEXP? {
    return(SEXP?.protectedSEXP)
  }
}

extension Array where Element == Double {
  
  /// Create a Swift Double Array from an R real vector
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
  
  /// Provide a SEXP representation (real vector) of this Double Array
  var SEXP: SEXP? {
    let realVec = RPROTECT(Rf_allocVector(SEXPTYPE(REALSXP), count))
    defer { RUNPROTECT(1) }
    let REALVEC =  REAL(realVec)
    for (idx, elem) in enumerated() { REALVEC![idx] = elem }
    return(realVec)
  }
  
  /// Provide a protected SEXP representation (real vector) of this Double Array
  /// - Important: the caller is responsible for UNPROTECTing it
  var protectedSEXP: SEXP? {
    return(SEXP?.protectedSEXP)
  }
}

extension Array where Element == Int {
  
  /// Create a Swift Int Array from an R integer vector
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
  
  /// Provide a SEXP representation (integer vector) of this Int Array
  var SEXP: SEXP? {
    let intVec = RPROTECT(Rf_allocVector(SEXPTYPE(INTSXP), count))
    defer { RUNPROTECT(1) }
    let INTEGERVEC = INTEGER(intVec)
    for (idx, elem) in enumerated() { INTEGERVEC![idx] = CInt(elem) }
    return(intVec)
  }

  /// Provide a protected SEXP representation (integer vector) of this Int Array
  /// - Important: the caller is responsible for UNPROTECTing it
  var protectedSEXP: SEXP? {
    return(SEXP?.protectedSEXP)
  }
}

extension Array where Element == String {
  
  /// Create a Swift String Array from an R character vector
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
  
  /// Provide a SEXP representation (character vector) of this String Array
  var SEXP: SEXP? {
    let charVec = RPROTECT(Rf_allocVector(SEXPTYPE(STRSXP), count))
    defer { RUNPROTECT(1) }
    for (idx, elem) in enumerated() { SET_STRING_ELT(charVec, idx, Rf_mkChar(elem)) }
    return(charVec)
  }
  
  /// Provide a protected SEXP representation (character vector) of this String Array
  /// - Important: the caller is responsible for UNPROTECTing it
  var protectedSEXP: SEXP? {
    return(SEXP?.protectedSEXP)
  }
}

extension Array where Element == SEXP {
  /// Unprotect all non-nil elements of this SEXP Array
  func UNPROTECT() {
    RUNPROTECT(CInt(filter { $0 != R_NilValue }.count))
  }
}

extension SEXP {
  
  /// Property wrapper for Rf_length()
  var length: R_len_t {
    Rf_length(self)
  }
  
  /// Property wrapper for Rf_length() b/c .count is more idiomatic in Swift
  var count: R_len_t {
    Rf_length(self)
  }
  
  /// Property wrapper for TYPEOF()
  var typeOf: SEXPTYPE {
    SEXPTYPE(TYPEOF(self))
  }
  
  /// Property wrapper for Rf_type2char(TYPEOF())
  var type: String {
    String(cString: Rf_type2char(SEXPTYPE(TYPEOF(self))))
  }
  
  /// Is this SEXP an LGLSXP?
  var isLOGICAL: Bool {
    self.typeOf == LGLSXP
  }
  
  /// Is this SEXP a REALSXP?
  var isREAL: Bool {
    self.typeOf == REALSXP
  }
  
  /// Is this SEXP an INTSXP?
  var isINTEGER: Bool {
    self.typeOf == INTSXP
  }
  
  /// Is this SEXP a StRSXP?
  var isSTRING: Bool {
    self.typeOf == STRSXP
  }
  
  /// Is this SEXP a VECSXP?
  var isLIST: Bool {
    self.typeOf == VECSXP
  }
  
  /// is this SEXP a RAWSXP?
  var isRAW: Bool {
    self.typeOf == RAWSXP
  }
  
  /// is this SEXP NULL?
  var isNULL: Bool {
    self == R_NilValue
  }
  
  /// are any of the elements of this SEXP NA?
  var anyNA: Bool? {
    do {
      return(Bool(try Rlang2(Rf_install("anyNA"), x:self)))
    } catch {
      return(nil)
    }
  }
  
  /// Property wrapper to retreive the mode of this SEXP
  var mode: String? {
    do {
      return(try String(Rlang2(R_ModeSymbol, x: self)))
    } catch {
      return(nil)
    }
  }
  
  /// Property wrapper to retrieve the names of this SEXP
  var namesAttrib: [String]? {
    [String](Rf_getAttrib(self, R_NamesSymbol))
  }
  
  /// Property wrapper to retrieve the class of this SEXP
  var classAttrib: [String]? {
    [String](Rf_getAttrib(self, R_ClassSymbol))
  }
  
  /// Provide a protected SEXP
  /// - Important: the caller is responsible for UNPROTECTing it
  var protectedSEXP: SEXP {
    RPROTECT(self)
  }
}

#include "swift-r-bridge.h"

int ct = 0;

/// Initialize embedded R with the given R_HOME
///
/// - Parameter x R_HOME
int initEmbeddedR(const char *r_home) {
  setenv("R_HOME", r_home, 1);
  char *argv[] = { "swiftR", "--gui=none", "--no-save", "--silent", "--vanilla", "--slave", "--no-readline", "" };
  return(Rf_initEmbeddedR(7, argv));
}

/// Wrapper for Rprintf since C variadic functions aren't supported in Swift
///
/// Parameter message string to print
void printFromR(const char *message) {
  Rprintf(message);
}

/// Wrapper for PROTECT since that C macro is not supported in Swift
///
/// Parameter x the SEXP to protect
inline SEXP RPROTECT(SEXP x) {
//  ct++;
//  printf("+1; ct: %d\n", ct);
  return(PROTECT(x));
}

/// Wrapper for UNPROTECT since that C macro is not supported in Swift
///
/// Parameter x how many protected SEXPs to unprotect
inline void RUNPROTECT(int x) {
//  ct--;
//  printf("-1; ct: %d\n", ct);
  UNPROTECT(x);
}

/// Get a C string from an R string
///
/// Primarily created b/c CHAR macro is not supported in Swift
///
/// Parameter x the R string (SEXP) to turn into a C string
inline const char *CHAR_Rf_asChar(SEXP x) {
  return(CHAR(Rf_asChar(x)));
}

/// Get a C string from the specified index in an R character vector
///
/// Primarily created b/c CHAR macro is not supported in Swift
///
/// Parameter x an R character vector (SEXP)
/// Parameter i the index of the string to retrieve and convert
inline const char *RVecElToCstr(SEXP x, R_xlen_t i) {
  return(CHAR(STRING_ELT(x, i)));
}

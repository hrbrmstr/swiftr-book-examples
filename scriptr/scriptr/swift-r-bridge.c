#include "swift-r-bridge.h"

void initEmbeddedR() {
  if (!getenv("R_HOME")) setenv("R_HOME", "/Library/Frameworks/R.framework/Resources", 1);
  char *argv[] = { "swiftR", "--gui=none", "--no-save", "--silent", "--vanilla", "--slave", "--no-readline", "" };
  Rf_initEmbeddedR(7, argv);
}

void printFromR(const char *message) {
  Rprintf(message);
}

inline SEXP RPROTECT(SEXP x) {
  return(PROTECT(x));
}

inline void RUNPROTECT(int x) {
  UNPROTECT(x);
}

inline const char *CHAR_Rf_asChar(SEXP x) {
  return(CHAR(Rf_asChar(x)));
}

inline const char *RVecElToCstr(SEXP x, R_xlen_t i) {
  return(CHAR(STRING_ELT(x, i)));
}

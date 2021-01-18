#ifndef swift_r_bridge_h
#define swift_r_bridge_h

#define USE_RINTERNALS

#include <R.h>
#include <Rinternals.h>
#include <Rembedded.h>
#include <R_ext/Print.h>
#include <R_ext/Parse.h>

//int initEmbeddedR(void);
int initEmbeddedR(const char *r_home);
void printFromR(const char *message);
SEXP RPROTECT(SEXP x);
void RUNPROTECT(int x);
const char *CHAR_Rf_asChar(SEXP x);
const char *RVecElToCstr(SEXP x, R_xlen_t i);

#endif /* swift_r_bridge_h */

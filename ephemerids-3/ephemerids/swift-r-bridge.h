#ifndef swift_r_bridge_h
#define swift_r_bridge_h

#define USE_RINTERNALS

#include <R.h>
#include <Rinternals.h>
#include <Rembedded.h>
#include <R_ext/Print.h>

void initEmbeddedR(void);
void printFromR(const char *message);
SEXP RPROTECT(SEXP x);
void RUNPROTECT(int x);
const char *CHAR_Rf_asChar(SEXP x);

#endif /* swift_r_bridge_h */

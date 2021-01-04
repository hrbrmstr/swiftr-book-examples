#include "swift-r-bridge.h"

void initEmbeddedR() {
  if (!getenv("R_HOME")) setenv("R_HOME", "/Library/Frameworks/R.framework/Resources", 1);
  char *argv[] = { "swiftR", "--gui=none", "--no-save", "--silent", "--vanilla", "--slave", "--no-readline", "" };
  Rf_initEmbeddedR(7, argv);
  R_ReplDLLinit();
}

void printFromR(const char *message) {
  Rprintf(message);
}

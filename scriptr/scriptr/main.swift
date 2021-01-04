import Foundation

initEmbeddedR()

// if we care about the returned SEXP use a variable instead of _
let _ = R_ParseEvalString("""
cat("Hello, World!\n")
""", R_GlobalEnv)

let vectorToParse = ["""
cat("Hello, again, World!\n")
"""].protectedSEXP
defer { RUNPROTECT(1) }

var status: ParseStatus = PARSE_OK
let parsed = RPROTECT(R_ParseVector(vectorToParse, -1, &status, R_NilValue))
defer { RUNPROTECT(1)}

if (status == PARSE_OK) {
  var rErr: CInt = 0
  for idx in 0..<Rf_length(parsed) {
    let _ = R_tryEvalSilent(VECTOR_ELT(parsed, R_xlen_t(idx)), R_GlobalEnv, &rErr)
    if (rErr != 0) {
      debugPrint("Eval failure: \(String(cString: R_curErrorBuf()))")
    }
  }
} else {
  debugPrint("Parse failure")
}

let _ = safeSilentEvalParse(["""
cat("Hello, again, World!\n")
"""])

let vecToParse = [
  "'Hello, yet again, World!'",
  "2020 + 1", "2020L + 1L",
  "FALSE",
  "head(letters, 10)",
  "ChickWeight$weight[1:10]",
  "as.integer(ChickWeight$weight[1:10])",
  "head(letters) == 'b'",
  "mtcars",
  "'Goodbye, World!'"
]

let parsedProtectedSEXPs = safeSilentEvalParse(vecToParse)

parsedProtectedSEXPs.forEach { sexp in
  if (sexp != R_NilValue) {
    if (sexp.isSTRING) {
      if (sexp.count == 1) {
        print("Evaluated result: <chr> \(String(cString: CHAR_Rf_asChar(sexp)))")
      } else {
        print("Evaluated result: [<chr>] \([String](sexp)!)")
      }
    } else if (sexp.isREAL) {
      if (sexp.count == 1) {
        print("Evaluated result: <dbl> \(Double(sexp)!)")
      } else {
        print("Evaluated result: [<dbl>] \([Double](sexp)!)")
      }
    } else if (sexp.isINTEGER) {
      if (sexp.count == 1) {
        print("Evaluated result: <int> \(Int(sexp)!)")
      } else {
        print("Evaluated result: [<int>] \([Int](sexp)!)")
      }
    } else if (sexp.isLOGICAL) {
      if (sexp.count == 1) {
        print("Evaluated result: <lgl> \(Bool(sexp)!)")
      } else {
        print("Evaluated result: [<lgl>] \([Bool](sexp)!)")
      }
    } else {
      print("Evaluted result is of type <\(sexp.type)> which we do not handle yet")
    }
  }
}

parsedProtectedSEXPs.UNPROTECT()


let res = safeSilentEvalParseString("mtcars")
defer { res.UNPROTECT() }

if (res.count == 1) {
  let mtcars = res[0]

  print(mtcars.classAttrib!)
  print(mtcars.namesAttrib!)
  print(mtcars.mode!)
  print(mtcars.anyNA!)
}

Rf_endEmbeddedR(0)

//
//let app = ["""
//library(shiny)
//
//runApp(list(
//    ui = bootstrapPage(
//      numericInput('n', 'Number of obs', 100),
//      plotOutput('plot')
//    ),
//    server = function(input, output) {
//      output$plot <- renderPlot({ hist(runif(input$n)) })
//    }
//  ))
//"""]
//
//let appRes = safeSilentEvalParse(app)
//appRes.UNPROTECT()


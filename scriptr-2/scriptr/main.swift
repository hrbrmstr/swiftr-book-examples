import Foundation
import ArgumentParser

initEmbeddedR()

let calculateMeanPerPatient = safeSilentEvalParseString("""
# https://swcarpentry.github.io/r-novice-inflammation/05-cmdline/index.html
calculate_mean_per_patient <- function(filename) {

  if (file.exists(filename)) {

    dat <- read.csv(file = filename, header = FALSE)
    mean_per_patient <- apply(dat, 1, mean)
    out <- jsonlite::toJSON(mean_per_patient, pretty = TRUE)

    cat(out, "\n", sep = "")

    return(0L)

  } else {
    cat("[]\n")
    return(1L)
  }

}
""")

var ret: CInt = 0

struct MeanR: ParsableCommand {

  @Argument(help: "CSV file to analyze")
  var csvFile: String = "~/books/swiftr/repo/data/inflammation-01.csv"

  mutating func run() throws {
    let res = try Rlang2(calculateMeanPerPatient[0], x: csvFile.protectedSEXP)
    defer { RUNPROTECT(1) }
    if (res.isINTEGER) {
      ret = CInt(Int(res)!)
    }
  }

}

MeanR.main()

Rf_endEmbeddedR(0)

exit(ret)


// MARK: Uncomment this section to get the bare metal R stats app

//import Foundation
//
//initEmbeddedR()
//
//var ret: CInt = 0
//
//let res = safeSilentEvalParseString("""
//# https://swcarpentry.github.io/r-novice-inflammation/05-cmdline/index.html
//
//filename <- "\(CommandLine.arguments[1])"
//
//if (file.exists(filename)) {
//
//  dat <- read.csv(file = filename, header = FALSE)
//  mean_per_patient <- apply(dat, 1, mean)
//  out <- jsonlite::toJSON(mean_per_patient, pretty = TRUE)
//
//  cat(out, "\n", sep = "")
//
//  0L
//
//} else {
//  cat("[]\n")
//  1L
//}
//""")
//
//ret = ((res.count == 1) && (res[0].isINTEGER)) ? CInt(Int(res[0])!) : 1
//
//Rf_endEmbeddedR(0)
//
//exit(ret)


// MARK: Uncomment this section to get the Shiny app

//import Foundation
//
//initEmbeddedR()
//
//let _ = safeSilentEvalParseString("""
//library(shiny)
//
//runApp(list(
//  ui = bootstrapPage(
//    numericInput('n', 'Number of obs', 100),
//    plotOutput('plot')
//  ),
//  server = function(input, output) {
//    output$plot <- renderPlot({ hist(runif(input$n)) })
//  }
//))
//""")
//
//Rf_endEmbeddedR(0)
//

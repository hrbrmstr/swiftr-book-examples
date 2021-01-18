import Foundation

class DensityModel : ObservableObject {
  
  @Published var plotData: Data = Data()
  @Published var kernel = "gaussian"
  @Published var bandwidth = 100.0
  @Published var rCmd = "c(rnorm(100, 0, 1), rnorm(50, 5, 1))"
  
  init() {
    
    initEmbeddedR()
    
    let _ = safeSilentEvalParseString("""
suppressPackageStartupMessages({
  library(ggplot2)
  library(magick)
  library(hrbrthemes)
})
""", showMessage: false)
    
    updatePlot()
    
  }
  
  func updatePlot() {
    
    if (parseStatus(rCmd) != PARSE_OK) { return() }
    
    debugPrint("Plotting")
    
    let res = safeSilentEvalParseString("""
suppressMessages(suppressWarnings(tryCatch({

  bw <- \(bandwidth)
  kernel <- "\(kernel)"
  x <- \(rCmd)

  ggplot() +
    stat_density(
      aes(x),
      bw = bw/100,
      kernel = kernel,
      geom = "line"
    ) +
    geom_point(
      aes(x, rep(0, length(x))), alpha = 1/4
    ) +
    scale_x_continuous(limits = range(x) + c(-2, 2)) +
    labs(
      title = sprintf("Kernel: %s", kernel),
      x = sprintf("N = %s • Bandwidth = %s", length(x), bw/100),
      y = "Density"
    ) +
    theme_ipsum_gs(grid="XY") -> gg

  image_graph(
    width = 480*2,
    height = 240*2,
    pointsize = 12,
    res = 144
  ) -> plt

  print(gg)

  dev.off()

  image_write(plt, path = NULL, format = "jpeg")

})))
""",  showMessage: true)
    
    // if everything is OK, change up plot data, otherwise keep current plot data
    
    if (res.count >= 0) {
      if (res.last!.isRAW) {
        plotData = Data(res.last!)! // there will be ~8 evaluated expressions
      }
    }
    
    R_gc()
    
  }
  
  deinit {
    Rf_endEmbeddedR(0)
  }
  
}

import Foundation

class AppGlobals {
    
  static let PLOT_WIDTH: CGFloat = 600
  static let PLOT_HEIGHT: CGFloat = 350

  static let MIN_BANDWIDTH: Double = 0.05
  static let MAX_BANDWIDTH: Double = 2
  static let BANDWIDTH_RANGE: ClosedRange<Double> = MIN_BANDWIDTH...MAX_BANDWIDTH // Range for our bandwidth slider
  static let DEFAULT_BANDWIDTH: Double = 1
  static let BANDWIDTH_DISPLAY_DECIMALS: Int = 4

  static let DENSITY_SCRIPT_SHA2565: String = "SHA256 digest: 161ba060f6c40c2bb70d9e02e3389d26ae8c47d0ad1a5e3985a46ae97c4a409b"
  static let DEFAULT_R_CMD: String = "c(rnorm(100, 0, 1), rnorm(50, 5, 1))\n\n\n"
  
}

class RGlobals {
  static let plot_width:String = "plot_width"
  static let plot_height:String = "plot_height"
  static let bw_digits:String = "bw_digits"
  static let x:String = "x"
  static let bw:String = "bw"
  static let kernel:String = "kernel"
}

class LocalizationStrings {
  // help
  static let DENSITY_SCRIPT_MISSING: String = "DENSITY-SCRIPT-MISSING".localized
  static let DENSITY_SCRIPT_MODIFIED: String = "DENSITY-SCRIPT-MODIFIED".localized
  static let BANDWIDTH_HELP: String = "BANDWIDTH-HELP".localized
  static let KERNEL_HELP: String = "KERNEL-HELP".localized
  static let RCMD_HELP: String = "RCMD-HELP".localized
  static let PLOT_HELP: String = "PLOT-HELP".localized
  // labels
  static let DENSITY_ESTIMATION_KERNEL: String = "DENSITY-ESTIMATION-KERNEL".localized
  static let DENSITY_ESTIMATION_BANDWIDTH: String = "DENSITY-ESTIMATION-BANDWIDTH".localized
  static let R_CMD_LABEL: String = "R-CMD-LABEL".localized
  // error
  static let MISSING_PACKAGES_ERROR: String = "MISSING-PACKAGES-ERROR".localized
  static let R_INITIALIZATION_FAILED: String = "R-INITIALIZATION-FAILED".localized
  // window titles
  static let INIT_FAILURE: String = "INIT-FAILURE".localized
  static let INSTALL_PKGS: String = "INSTALL-PKGS".localized
  static let MAIN_TITLE: String = "MAIN-TITLE".localized
}

import Foundation
import CryptoKit

// TODO: Unify the models

// MARK: Model for view that handles missing packages
class PackagesModel: ObservableObject{

  @Published var missingPackages: [String] = []
  @Published var embeddedROK: Bool
  
  init() {
  
    let res = initEmbeddedR("/Library/Frameworks/R.framework/Resources")

    embeddedROK = (res == 1) // unfortunately this is always the case
    
    if (embeddedROK) {
      do {
        
        let ggplotAvailable = try require("ggplot2")
        if (ggplotAvailable) {
          let hrbrthemesAvailable = try require("hrbrthemes")
          if (!hrbrthemesAvailable) { missingPackages.append("hrbrthemes") }
        } else {
          if (!ggplotAvailable) { missingPackages.append("ggplot2") }
        }
        
        let magickAvailable = try require("magick")
        if (!magickAvailable) { missingPackages.append("magick") }
        
      } catch {
        // Something rly went wrong if we got here so we eventually need to handle this
      }
    }
    
  }
  
}

// MARK: Model for the Density viewer application
class DensityModel : ObservableObject {

  @Published var plotData: Data = Data()
  @Published var kernel: String = ""
  @Published var availableKernels: [String] = [String]()
  @Published var bandwidth = AppGlobals.DEFAULT_BANDWIDTH
  @Published var rCmd = AppGlobals.DEFAULT_R_CMD
  @Published var rCmdOK: Bool = true
  
  private var parsedRScript: SEXP = R_NilValue
 
  init() {
    
    // do the initial eval on the default R values generation code
    let res: [SEXP] = safeSilentEvalParseString("eval(formals(density.default)$kernel)")
      
    if (res.last != R_NilValue) { // R is working
      
      defer { res.UNPROTECT() }

      // get the kernel strings
      let kernels = [String](res.last!)!
      
      // make them available to swift and the content view
      self.availableKernels = kernels.map { $0.capitalizingFirstLetter() }
      self.kernel = self.availableKernels.first!
      
      // define some R globals (that are more 'constant-y')
      defineGlobal(RGlobals.plot_width, Double(AppGlobals.PLOT_WIDTH).SEXP)
      defineGlobal(RGlobals.plot_height, Double(AppGlobals.PLOT_HEIGHT).SEXP)
      defineGlobal(RGlobals.bw_digits, 4.SEXP)
      
      validateRCmd() // generate the initial data and assign it (technically we should set the seed too)
      
      // load the R script from the bundle
      guard let densityScriptPath = Bundle.main.path(forResource: "density", ofType: "rstats") else {
        fatalError(LocalizationStrings.DENSITY_SCRIPT_MISSING)
      }

      // read it in
      // try! is a little dangerous but it should be safe here
      let densityScript = try! String(contentsOfFile: densityScriptPath)
      
      // this is far from a perfect way to ensure the script has not been modified
      // (go to a terminal, find the SwiftDensity binary and do
      //     $ strings | grep 43fff23f4d5d86a62d743a96c477b78a8239ab8fc8dc7df2482447fc1c49ec01
      // if you don't believe me.
      // dealing with resource protection in a more thorough way is beyond the scope of this exercise.
      if (SHA256.hash(data: densityScript.data(using: .utf8)!).description != AppGlobals.DENSITY_SCRIPT_SHA2565) {
        fatalError(LocalizationStrings.DENSITY_SCRIPT_MODIFIED)
      }
      
      // parse the R script only once
      parsedRScript = parseRScript(densityScript).protectedSEXP // need to ensure we RUNPROTECT this
      
    }
    
    updatePlot() // we want to start with a plot
    
  }

  /// Called to when rCmd is updated to determine if it is parse-able R code
  ///
  ///
  /// - Does the input R expressions parse?
  /// - Does it eval OK?
  /// - Does it have a compatible type?
  /// - Is the length of the vector >= 2?
  ///
  /// There is a side-effect of the R global "x" being populated with the evaluated, parsed statement.s
  func validateRCmd() {
    let res = safeSilentEvalParseString(rCmd, showMessage: true)
    defer { res.UNPROTECT() }
    rCmdOK = (res.first != R_NilValue) && ((res.first!.isREAL) || (res.first!.isINTEGER)) && (res.count >= 1)
    if (rCmdOK) {
      defineGlobal("x", res.first!)
    }
  }
  
  /// Called when the plot panel should be updated
  func updatePlot() {
            
    defineGlobal(RGlobals.bw, bandwidth.SEXP) // update bandwidth
    defineGlobal(RGlobals.kernel, kernel.lowercased().SEXP) // update kernel

    // at least we're not parsing it each time
    let res: [SEXP] = evalSEXP(parsedRScript)
    defer { res.UNPROTECT() }

    // if everything is OK, change up plot data, otherwise keep current plot data
    
    if (res.count >= 0) {
      if (res.last!.isRAW) {
        plotData = Data(res.last!)! // there will be ~8 evaluated expressions
      }
    }
    
    R_gc()
    
  }
  
  deinit {
    RUNPROTECT(1) // parsedRScript from init()
    Rf_endEmbeddedR(0)
  }
  
}

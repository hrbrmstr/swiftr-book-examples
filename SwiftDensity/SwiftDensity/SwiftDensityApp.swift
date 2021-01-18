import SwiftUI

@main
struct SwiftDensityApp: App {
  
  @ObservedObject var packagesModel: PackagesModel = PackagesModel()
  
  var body: some Scene {
    
    WindowGroup {
      
      if (!packagesModel.embeddedROK) { // MARK: R startup was 😭
        
        EmbeddedRErrorView()
          .navigationTitle(LocalizationStrings.INIT_FAILURE)
          .fixedSize()
        
      } else if (packagesModel.missingPackages.count > 0) { // MARK: We're missing some 📦
        
        InstallPackagesView(packages: packagesModel.missingPackages)
          .navigationTitle(LocalizationStrings.INSTALL_PKGS)
          .fixedSize()
          .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
            Rf_endEmbeddedR(0)
          }
        
      } else { // MARK: All is 👍🏽
        
        ContentView()
          .navigationTitle(LocalizationStrings.MAIN_TITLE)
          .fixedSize()
          .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
            Rf_endEmbeddedR(0)
          }
        
      }
    }
    .commands {
      CommandGroup(replacing: CommandGroupPlacement.newItem) { }
    }
  }
}

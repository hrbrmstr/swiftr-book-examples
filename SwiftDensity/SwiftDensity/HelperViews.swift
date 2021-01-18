import Foundation
import SwiftUI

struct InstallPackagesView: View {
  var packages: [String]
  var body: some View {
    VStack {
      Text("\(LocalizationStrings.MISSING_PACKAGES_ERROR):").padding()
      ForEach (packages, id: \.self) { Text($0) } .padding()
    }
    .padding()
  }
}

struct EmbeddedRErrorView: View {
  var body: some View {
    VStack {
      Text(LocalizationStrings.R_INITIALIZATION_FAILED).padding()
    }
    .padding()
  }
}

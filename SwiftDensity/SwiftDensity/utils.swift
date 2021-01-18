import Foundation
import SwiftUI

extension Color {
  static let codeError = Color("codeError")
  static let codeOK = clear
}

extension Date {
  
  /// Enables passing in of e.g. "2021-01-01" to get a Date
  init(fromISODate: String) {
    self = Date.iso8601Formatter.date(from: fromISODate)!
  }
  
  /// Provides an e.g. "2021-01-01" string representation of a Date
  var ISODate: String {
    Date.iso8601Formatter.string(from: self)
  }
  
  static let iso8601Formatter: ISO8601DateFormatter = {
    let fmt = ISO8601DateFormatter()
    fmt.formatOptions = [ .withFullDate, .withDashSeparatorInDate ]
    return(fmt)
  }()
  
}

extension Double {
  
  /// Provides e.g. 3 from 3.14
  var whole: Self { rounded(.toNearestOrAwayFromZero) }
  
  /// Provides e.g. 0.14 from 3.14
  var fraction: Self { truncatingRemainder(dividingBy: 1) }
  
  /// Provides e.g. "05:30" from 5.5
  var decimalTimeToHM: String {
    return(String(format: "%02d:%02d", Int(whole), Int(fraction*60)))
  }
  
  /// Rounds a double to a specified number of decimal digits
  func roundToDecimal(_ fractionDigits: Int) -> Double {
    let multiplier = pow(10, Double(fractionDigits))
    return Darwin.round(self * multiplier) / multiplier
  }
  
}

extension String {
  func capitalizingFirstLetter() -> String {
    return prefix(1).capitalized + dropFirst()
  }
  
  mutating func capitalizeFirstLetter() {
    self = self.capitalizingFirstLetter()
  }
  
  var localized: String {
     NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
  }
}

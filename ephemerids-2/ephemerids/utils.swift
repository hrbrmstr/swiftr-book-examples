import Foundation

extension Date {
  
  init(fromISODate: String) {
    self = Date.iso8601Formatter.date(from: fromISODate)!
  }
  
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
  
  var whole: Self { rounded(.toNearestOrAwayFromZero) }
  var fraction: Self { truncatingRemainder(dividingBy: 1) }
  
  var decimalTimeToHM: String {
    return(String(format: "%02d:%02d", Int(whole), Int(fraction*60)))
  }

}

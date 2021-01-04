import Foundation
import ArgumentParser

struct Sunriset: ParsableCommand {
  
  static var configuration = CommandConfiguration(
    abstract: "Outputs sunrise/sunset times for a given longitude/latitude for today or a speficied date. ",
    discussion: "Use -- before positional parameters if any are negative.\ne.g. ephemerids -- -70.8636 43.2683"
  )
  
  @Option(help: "A ISO3601 date. — e.g. 2021-01-01") var date: String = Date().ISODate // default --date= to today

  @Argument(help: "Longitude, decimal — e.g. -70.8636. ")
  var lng: Double = -70.8636 // provide a default

  @Argument(help: "Latitude, decimal — e.g. 43.2683. Use -- before positional parameters if any are negative.")
  var lat: Double = 43.2683 // provide a default

  mutating func run() throws {
    doSunRiseSet(date: Date(fromISODate: date), lng: lng, lat: lat)
  }

}

initEmbeddedR()

Sunriset.main()

Rf_endEmbeddedR(0)

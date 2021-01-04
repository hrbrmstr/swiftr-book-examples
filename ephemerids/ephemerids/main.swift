import Foundation

initEmbeddedR()

do {
  if try require("daybreak") {
    let res = sunRiseSet(date: Date(fromISODate: "2021-01-09"), lng: 43.2683, lat: -70.8636)
    print("Sunrise: \(res.rise.decimalTimeToHM) GMT\n Sunset: \(res.set.decimalTimeToHM) GMT")
  } else {
    print("The {daybreak} package is not available. Please remotes::install_github('hrbrmstr/daybreak')")
  }
} catch {
  print("Error: \(error)")
}

Rf_endEmbeddedR(0)

import Foundation

struct sunriset {
  let rise: Double
  let set: Double
}

// sun_rise_set("2021-01-02", lon = -70.8636, lat = 43.2683)
// ## $rise
// ## [1] 12.25761
// ##
// ## $set
// ## [1] 21.28906
func sunRiseSet(date: Date, lng: Double, lat: Double) -> sunriset {
  
  var err: CInt = 0
  
  let call_ƒ = RPROTECT(
    Rf_lang4(
      Rf_install("sun_rise_set"),
      date.ISODate.protectedSEXP,
      lng.protectedSEXP,
      lat.protectedSEXP
    )
  )
  defer { RUNPROTECT(4) }
  
  let res: SEXP = RPROTECT(R_tryEvalSilent(call_ƒ, R_GlobalEnv, &err)) ?? R_NilValue
  defer { RUNPROTECT(1) }

  return(sunriset(
    rise: Double(VECTOR_ELT(res, 0)) ?? -1,
     set: Double(VECTOR_ELT(res, 1)) ?? -1
  ))

}

func doSunRiseSet(date: Date, lng: Double, lat: Double) {

  do {
    if try require("daybreak") {
      let res = sunRiseSet(date: date, lng: lng, lat: lat)
      print("Sunrise 🌅: \(res.rise.decimalTimeToHM) GMT\n Sunset 🌇: \(res.set.decimalTimeToHM) GMT")
    } else {
      print("The {daybreak} package is not available. Please remotes::install_github('hrbrmstr/daybreak')")
    }
  } catch {
    print("Error: \(error)")
  }

}

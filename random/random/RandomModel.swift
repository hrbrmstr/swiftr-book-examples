import Foundation

class RandomModel : ObservableObject {
  
  init() {
    initEmbeddedR("/Library/Frameworks/R.framework/Resources")
  }
  
  /// Set R's random seed
  ///
  /// Calls `set.seed()` with the provided seed
  ///
  /// - Parameter seed: a single value, interpreted as an integer
  func setSeed(_ seed: Int) {
    do {
      _ = try Rlang2(Rf_install("set.seed"), x: seed.protectedSEXP)
      RUNPROTECT(1)
    } catch {
    }
  }
  
  /// Random samples
  ///
  /// Takes a sample of the specified `size` from `rangeStart`:`rangeEnd` with replacement.
  ///
  /// The random seed is first set with `set.seed(seed = seed)` and then `sample()` is called
  /// to generate the values which are then turned into a comma-separated string with `toString()`
  /// (all in R).
  ///
  /// - Parameters:
  ///   - rangeStart: start of the range to sample from
  ///   - rangeEnd: end of the range to sample from
  ///   - size: a non-negative integer giving the number of items to choose.
  ///   - seed: the random seed to use
  func sample(rangeStart: Int, rangeEnd: Int, size: Int, seed: Int) -> String {
    setSeed(seed)
    let rCode = "toString(sample(x = \(rangeStart):\(rangeEnd), size = \(size), replace = TRUE))"
    let res = safeSilentEvalParseString(rCode)
    R_gc()
    return(String(res[0]) ?? "")
  }
  
  deinit { Rf_endEmbeddedR(0) }

}

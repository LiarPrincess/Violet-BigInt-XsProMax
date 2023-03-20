extension BigInt {

  /// Special `init` function for 'Main' target, so that we do not see
  /// `BigInt` initialization in instruments.
  ///
  /// Not a part of an official API (and compilation flags are annoying).
  public static func initFast<T: FixedWidthInteger>(
    isPositive: Bool,
    magnitude: [T]
  ) -> BigInt {
    assert(!T.isSigned)

    guard T.bitWidth == Word.bitWidth else {
      trap("Fast init is only available for unsigned \(Word.bitWidth) bit integers.")
    }

    var result = BigInt()

    if magnitude.isEmpty {
      return result
    }

    let count = magnitude.count
    let token = result.storage.guaranteeUniqueBufferReference(withCapacity: count)

    magnitude.withContiguousStorageIfAvailable { tPtr in
      tPtr.withMemoryRebound(to: BigIntStorage.Word.self) { wordsPtr in
        result.storage.replaceAllAssumingCapacity(token, withContentsOf: wordsPtr)
      }
    }

    result.storage.fixInvariants(token)
    result.storage.checkInvariants()

    if !isPositive {
      result.negate()
    }

    return result
  }
}

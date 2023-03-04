extension BigInt {

  // Do not implement '+'!
  // Use the default implementation from protocol, it is 1000x faster.

  // MARK: - Negate

  public static prefix func - (value: BigInt) -> BigInt {
    var result = value
    result.negate()
    return result
  }

  public mutating func negate() {
    // Zero is always positive
    if self.isZero {
      assert(self.isPositiveOrZero)
      return
    }

    self.storage.isNegative.toggle()
    self.storage.checkInvariants()
  }

  // MARK: - Invert

  public static prefix func ~ (value: BigInt) -> BigInt {
    var result = value
    result.add(other: Word(1))
    result.negate()
    return result
  }
}

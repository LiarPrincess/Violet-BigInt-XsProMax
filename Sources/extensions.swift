// MARK: - Integer + predicates

extension BigIntStorage.Word {
  internal var isZero: Bool { return self == 0 }
  internal var isNegative: Bool { return self < 0 }
}

extension Int {
  internal var isZero: Bool { return self == 0 }
  internal var isNegative: Bool { return self < 0 }
}

// MARK: - Word + maxRepresentablePower

extension BigIntStorage.Word {

  /// Returns the highest number that satisfy `radix^n <= 2^Self.bitWidth`
  internal static func maxRepresentablePower(of radix: Self) -> (n: Int, power: Self) {
    var n = 1
    var power = radix

    while true {
      let (newPower, overflow) = power.multipliedReportingOverflow(by: radix)

      if overflow {
        return (n, power)
      }

      n += 1
      power = newPower
    }
  }
}

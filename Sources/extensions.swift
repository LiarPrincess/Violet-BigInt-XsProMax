// MARK: - Integer + predicates

extension BigIntStorage.Word {
  internal var isZero: Bool { return self == 0 }
  /// Including `0`.
  internal var isPositive: Bool { return self >= 0 }
  internal var isNegative: Bool { return self < 0 }
}

extension Int {
  internal var isZero: Bool { return self == 0 }
  /// Including `0`.
  internal var isPositive: Bool { return self >= 0 }
  internal var isNegative: Bool { return self < 0 }
}

// MARK: - Word + full width

extension BigIntStorage.Word {

  internal typealias FullWidthAdd = (carry: Self, result: Self)

  /// `result = self + y`
  internal func addingFullWidth(_ y: Self) -> FullWidthAdd {
    let (result, overflow) = self.addingReportingOverflow(y)
    let carry: Self = overflow ? 1 : 0
    return (carry, result)
  }

  /// `result = self + y + z`
  internal func addingFullWidth(_ y: Self, _ z: Self) -> FullWidthAdd {
    let (xy, overflow1) = self.addingReportingOverflow(y)
    let (xyz, overflow2) = xy.addingReportingOverflow(z)
    let carry: Self = (overflow1 ? 1 : 0) + (overflow2 ? 1 : 0)
    return (carry, xyz)
  }

  internal typealias FullWidthSub = (borrow: Self, result: Self)

  /// `result = self - y`
  internal func subtractingFullWidth(_ y: Self) -> FullWidthSub {
    let (result, overflow) = self.subtractingReportingOverflow(y)
    let borrow: Self = overflow ? 1 : 0
    return (borrow, result)
  }

  /// `result = self - y - z`
  internal func subtractingFullWidth(_ y: Self, _ z: Self) -> FullWidthSub {
    let (xy, overflow1) = self.subtractingReportingOverflow(y)
    let (xyz, overflow2) = xy.subtractingReportingOverflow(z)
    let borrow: Self = (overflow1 ? 1 : 0) + (overflow2 ? 1 : 0)
    return (borrow, xyz)
  }
}

// MARK: - Word + maxRepresentablePower

extension BigIntStorage.Word {

  /// Returns the highest number that satisfy `radix^n <= 2^Self.bitWidth`
  internal static func maxRepresentablePower(of radix: Int) -> (n: Int, power: Self) {
    var n = 1
    var power = Self(radix)

    while true {
      let (newPower, overflow) = power.multipliedReportingOverflow(by: Self(radix))

      if overflow {
        return (n, power)
      }

      n += 1
      power = newPower
    }
  }
}

// MARK: - UnicodeScalar + asDigit

extension UnicodeScalar {

  /// Try to convert scalar to digit.
  ///
  /// Acceptable values:
  /// - ascii numbers
  /// - ascii lowercase letters (a - z)
  /// - ascii uppercase letters (A - Z)
  internal var asDigit: BigIntStorage.Word? {
    // Tip: use 'man ascii':
    let a: BigIntStorage.Word = 0x61, z: BigIntStorage.Word = 0x7a
    let A: BigIntStorage.Word = 0x41, Z: BigIntStorage.Word = 0x5a
    let n0: BigIntStorage.Word = 0x30, n9: BigIntStorage.Word = 0x39

    let value = BigIntStorage.Word(self.value)

    if n0 <= value && value <= n9 {
      return value - n0
    }

    if a <= value && value <= z {
      return value - a + 10 // '+ 10' because 'a' is 10 not 0
    }

    if A <= value && value <= Z {
      return value - A + 10
    }

    return nil
  }
}

// MARK: - Scalar + code point notation

extension UnicodeScalar {

  /// U+XXXX (for example U+005F). Then you can use it
  /// [here](https://unicode.org/cldr/utility/character.jsp?a=005f)\.
  internal var codePointNotation: String {
    var numberPart = String(self.value, radix: 16, uppercase: true)

    if numberPart.count < 4 {
      let pad = String(repeating: "0", count: 4 - numberPart.count)
      assert(!pad.isEmpty)
      numberPart = pad + numberPart
    }

    return "U+\(numberPart)"
  }
}

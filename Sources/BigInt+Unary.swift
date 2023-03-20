extension BigInt {

  // Do not implement '+'!
  // Use the default implementation from protocol, it is 1000x faster.

  // MARK: - Negate

  public mutating func negate() {
    // 'isNegative' check is 1st, because 'isZero' does access heap.
    let isPositive = self.isNegative || self.isZero
    self.storage.isNegative = !isPositive
    self.storage.checkInvariants()
  }

  // MARK: - Invert

  public static prefix func ~ (value: BigInt) -> BigInt {
    // ~x = negate(x+1)
    // Writing this by hand is faster than:
    //   self.add(other: Word(1))
    //   self.negate()

    let count = value.storage.count
    var result = BigIntStorage(minimumCapacity: count)
    let token = result.guaranteeUniqueBufferReference()
    result.setCount(token, value: count)

    if value.isPositiveOrZero {
      Self.incrementMagnitude(src: value.storage, dst: &result, token)
    } else {
      Self.decrementMagnitude(src: value.storage, dst: &result, token)
    }

    result.isNegative = !value.isNegative
    result.checkInvariants()
    return BigInt(storageWithValidInvariants: result)
  }

  private static func incrementMagnitude(
    src: BigIntStorage,
    dst: inout BigIntStorage,
    _ token: UniqueBufferToken
  ) {
    let carry = src.withWordsBuffer { src -> Word in
      return dst.withMutableWordsBuffer(token) { dst -> Word in
        var carry: Word = 1

        for i in 0..<src.count {
          let (word, overflow) = src[i].addingReportingOverflow(carry)
          carry = overflow ? 1 : 0
          dst[i] = word
        }

        return carry
      }
    }

    if carry != 0 {
      dst.appendWithPossibleGrow(token, element: carry)
    }
  }

  private static func decrementMagnitude(
    src: BigIntStorage,
    dst: inout BigIntStorage,
    _ token: UniqueBufferToken
  ) {
    let newCount = src.withWordsBuffer { src -> Int in
      return dst.withMutableWordsBuffer(token) { dst -> Int in
        var borrow: Word = 1

        for i in 0..<src.count {
          let (word, overflow) = src[i].subtractingReportingOverflow(borrow)
          borrow = overflow ? 1 : 0
          dst[i] = word
        }

        assert(borrow == 0)

        // If the 'highestWord' was 1 and we borrowed from it then new count is smaller.
        let count = src.count
        let highestWord = dst[count - 1]
        return count - (highestWord == 0 ? 1 : 0)
      }
    }

    dst.setCount(token, value: newCount)
  }
}

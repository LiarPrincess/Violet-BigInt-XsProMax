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

    return value.isPositiveOrZero ?
      value.invertPositive() :
      value.invertNegative()
  }

  private func invertPositive() -> BigInt {
    let count = self.storage.count
    var result = BigIntStorage(minimumCapacity: count)
    let token = result.guaranteeUniqueBufferReference()
    result.setCount(token, value: count)

    let carry = self.storage.withWordsBuffer { src -> Word in
      return result.withMutableWordsBuffer(token) { dst -> Word in
        var carry: Word = 1

        for i in 0..<src.count {
          (carry, dst[i]) = src[i].addingFullWidth(carry)
        }

        return carry
      }
    }

    if carry != 0 {
      result.append(token, element: carry)
    }

    result.isNegative = true
    result.checkInvariants()
    return BigInt(storageWithValidInvariants: result)
  }

  private func invertNegative() -> BigInt {
    let count = self.storage.count
    var result = BigIntStorage(minimumCapacity: count)
    let token = result.guaranteeUniqueBufferReference()

    // This will be later overridden if we borrow from highest word.
    result.setCount(token, value: count)

    let highestWord = self.storage.withWordsBuffer { src -> Word in
      return result.withMutableWordsBuffer(token) { dst -> Word in
        var borrow: Word = 1

        for i in 0..<src.count {
          (borrow, dst[i]) = src[i].subtractingFullWidth(borrow)
        }

        assert(borrow == 0)
        return dst[count - 1]
      }
    }

    // If the 'highestWord' was 1 and we borrowed from it then our count is smaller.
    if highestWord == 0 {
      result.setCount(token, value: count - 1)
    }

    result.isNegative = false
    result.checkInvariants()
    return BigInt(storageWithValidInvariants: result)
  }
}

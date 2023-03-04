@testable import BigInt

// MARK: - BigIntStorage

extension BigIntStorage {

  internal init(isNegative: Bool, words: Word...) {
    self.init(isNegative: isNegative, words: words)
  }

  internal init(isNegative: Bool, words: [Word]) {
    if words.isEmpty {
      self = BigIntStorage.zero
      return
    }

    self.init(minimumCapacity: words.count)
    self.isNegative = isNegative

    let token = self.guaranteeUniqueBufferReference()
    for word in words {
      self.append(token, element: word)
    }
  }
}

extension BigInt {
  internal init(_ storage: BigIntStorage) {
    var copy = storage
    let token = copy.guaranteeUniqueBufferReference()
    copy.fixInvariants(token)
    self = BigInt(storageWithValidInvariants: copy)
  }
}

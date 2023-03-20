/// `Int` but bigger. Much bigger…
public struct BigInt: SignedInteger,
                      Comparable, Hashable, Strideable,
                      CustomStringConvertible, CustomDebugStringConvertible {

  internal typealias Word = BigIntStorage.Word
  internal typealias UniqueBufferToken = BigIntStorage.UniqueBufferToken

  // MARK: - Properties

  internal var storage: BigIntStorage

  internal var isZero: Bool {
    return self.storage.isZero
  }

  internal var isNegative: Bool {
    return self.storage.isNegative
  }

  internal var isPositiveOrZero: Bool {
    return !self.isNegative
  }

  internal var isMagnitude1: Bool {
    return self.storage.withWordsBuffer { $0.count == 1 && $0[0] == 1 }
  }

  // MARK: - Init

  public init() {
    self.init(storageWithValidInvariants: BigIntStorage.zero)
  }

  internal init(minimumStorageCapacity capacity: Int) {
    self.storage = BigIntStorage(minimumCapacity: capacity)
  }

  internal init(storageWithValidInvariants storage: BigIntStorage) {
    self.storage = storage
  }

  // MARK: - Init - Int

  public init<T: BinaryInteger>(_ value: T) {
    // Violet is a closed system, so no other >UInt64.max type is present.
    // Otherwise this would be much more complicated.
    if let big = value as? BigInt {
      self = big
    } else {
      // Assuming that biggest 'BinaryInteger' in Swift is representable by 'Word'.
      let isNegative = value < T.zero
      let magnitude = Word(value.magnitude)
      self.storage = BigIntStorage(isNegative: isNegative, magnitude: magnitude)
    }
  }

  public init(integerLiteral value: Int) {
    self.init(value)
  }

  public init?<T: BinaryInteger>(exactly source: T) {
    self.init(source)
  }

  public init<T: BinaryInteger>(truncatingIfNeeded source: T) {
    self.init(source)
  }

  public init<T: BinaryInteger>(clamping source: T) {
    self.init(source)
  }

  // MARK: - BinaryInteger

  // Custom overloads for performance.

  public var magnitude: BigInt {
    var storage = self.storage
    storage.isNegative = false
    storage.checkInvariants()
    return BigInt(storageWithValidInvariants: storage)
  }

  private static let plusOne = BigInt(1)
  private static let minusOne = BigInt(-1)

  public func signum() -> BigInt {
    // Avoid fetching
    if self.isNegative {
      return Self.minusOne
    }

    return self.isZero ? Self.zero : Self.plusOne
  }

  public func isMultiple(of other: BigInt) -> Bool {
    // Nothing but zero is a multiple of zero.
    if other.isZero {
      return self.isZero
    }

    let mod = self % other
    return mod.isZero
  }

  // MARK: - Power

  public func power(exponent: BigInt) -> BigInt {
    precondition(exponent >= 0, "Exponent must be positive")

    func is1(_ n: BigInt) -> Bool {
      return n.isPositiveOrZero && n.isMagnitude1
    }

    func isOdd(_ n: BigInt) -> Bool {
      return n.storage.withWordsBuffer { words in
        if words.isEmpty {
          assert(self.isZero)
          return true // '0' is even
        }

        return words[0] & 0b1 == 1
      }
    }

    if exponent.isZero {
      return BigInt(1)
    }

    if is1(exponent) {
      return self
    }

    // This has to be after 'exp == 0', because 'pow(0, 0) -> 1'
    if self.isZero {
      return 0
    }

    var base = self
    var exponent = exponent
    var result = BigInt(1)

    // Eventually we will arrive to most significant '1'
    while !is1(exponent) {
      if isOdd(exponent) {
        result *= base
      }

      base *= base
      exponent >>= 1 // Basically divided by 2, but faster
    }

    // Most significant '1' is odd:
    result *= base
    return result
  }
}

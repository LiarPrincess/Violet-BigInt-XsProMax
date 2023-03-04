// This file contains:
// - bitWidth
// - words
// - minRequiredWidth - this is for Python 'bit_length'
// - trailingZeroBitCount
//
// Those properties (except for 'minRequiredWidth') are crucial for Swift integer
// interop and well… they are quite tricky to get right.
//
// WARNING:
// This file is full of dark arcane magic (mostly involving bit operations)!
// Listen to this for best effect: https://youtu.be/ML0XFlWkEvk?t=298.

// MARK: - Magic spells

// For 4-bit words:
// +--------------------------------------|----------------------------------------+
// |               positive               |                negative                |
// +-----+-----------+------------+-------+------+------------+------------+-------+
// | dec |    bin    | needs sign |  bit  | -dec |    bin     | needs sign |  bit  |
// |     |           |    word    | width |      | (invert+1) |    word    | width |
// +-----+-----------+------------+-------+------+------------+------------+-------+
// |   0 |      0000 |         no |     1 |    0 |  1111 0000 | degenerate |     - |
// |   1 |      0001 |         no |     2 |   -1 |       1111 |         no |     1 |
// |   2 |      0010 |         no |     3 |   -2 |       1110 |         no |     2 |
// |   3 |      0011 |         no |     3 |   -3 |       1101 |         no |     3 |
// +-----+-----------+------------+-------+------+------------+------------+-------+
// |   4 |      0100 |         no |     4 |   -4 |       1100 |         no |     3 |
// |   5 |      0101 |         no |     4 |   -5 |       1011 |         no |     4 |
// |   6 |      0110 |         no |     4 |   -6 |       1010 |         no |     4 |
// |   7 |      0111 |         no |     4 |   -7 |       1001 |         no |     4 |
// +-----+-----------+------------+-------+------+------------+------------+-------+
// |   8 | 0000 1000 |        yes |     5 |   -8 |       1000 |         no |     4 |
// |   9 | 0000 1001 |        yes |     5 |   -9 |  1111 0111 |        yes |     5 |
// |  10 | 0000 1010 |        yes |     5 |  -10 |  1111 0110 |        yes |     5 |
// |  11 | 0000 1011 |        yes |     5 |  -11 |  1111 0101 |        yes |     5 |
// +-----+-----------+------------+-------+------+------------+------------+-------+
// |  12 | 0000 1100 |        yes |     5 |  -12 |  1111 0100 |        yes |     5 |
// |  13 | 0000 1101 |        yes |     5 |  -13 |  1111 0011 |        yes |     5 |
// |  14 | 0000 1110 |        yes |     5 |  -14 |  1111 0010 |        yes |     5 |
// |  15 | 0000 1111 |        yes |     5 |  -15 |  1111 0001 |        yes |     5 |
// +-----+-----------+------------+-------+------+------------+------------+-------+

private let bitWidthForZero = 1
// If the value is zero, then trailingZeroBitCount is equal to bitWidth, see:
// https://developer.apple.com/documentation/swift/binaryinteger/trailingzerobitcount
private let trailingZeroBitCountForZero = bitWidthForZero

private func hasMostSignificantBit1<T: FixedWidthInteger>(value: T) -> Bool {
  let mostSignificantBit = value >> (T.bitWidth - 1)
  return mostSignificantBit == 1
}

private func hasMostSignificantBit0<T: FixedWidthInteger>(value: T) -> Bool {
  return !hasMostSignificantBit1(value: value)
}

extension BigInt {

  // MARK: - Bit width

  public var bitWidth: Int {
    return self.storage.withWordsBuffer { words -> Int in
      if words.isEmpty {
        assert(self.isZero)
        return bitWidthForZero
      }

      let lastIndex = words.count - 1
      let last = words[lastIndex]
      let wordsWidth = words.count * Word.bitWidth
      let leadingZeroBitCount = last.leadingZeroBitCount

      func bitWidthForPositive() -> Int {
        // Positive numbers need leading '0',
        // because leading '1' marks negative number.
        let zeroAsSign = 1
        return wordsWidth - leadingZeroBitCount + zeroAsSign
      }

      if self.isPositiveOrZero {
        return bitWidthForPositive()
      }

      // For negative numbers we can use the same formula except for the case when
      // number is power of 2 (magnitude has single '1' and then a lot of '0').
      // In such case we do not have to add 'zeroAsSign'.
      //
      // Look at this (example for 4-bit word):
      // +------------------------+-------------------------------+
      // |        positive        |            negative           |
      // +-----+------+-----------+------+------------+-----------+
      // | dec | bin  | bit width | -dec |    bin     | bit width |
      // +-----+------+-----------+------+------------+-----------+
      // |   7 | 0111 | 4-1+1 = 4 |   -7 |       1001 |         4 |
      // |   8 | 1000 | 4-0+1 = 5 |   -8 |       1000 | THIS -> 4 |
      // |   9 | 1001 | 4-0+1 = 5 |   -9 |  1111 0111 |         5 |
      // +-----+------+-----------+------+------------+-----------+
      //
      // There is a bit more detailed explanation below.
      //
      // To quickly find powers of 2:
      // 1. most significant word is power of 2
      // 2. all other words are 0

      let isLastPowerOf2 = (last & (last - 1)) == 0
      guard isLastPowerOf2 else {
        return bitWidthForPositive()
      }

      // Check for all other words == 0
      for i in 0..<lastIndex where words[i] != 0 {
        return bitWidthForPositive()
      }

      // We are at our special case
      return wordsWidth - leadingZeroBitCount

      // OLD EXPLANATION:
      // Two complement:
      // 1. invert all words
      // 2. add 1
      // This 'add 1' step may require additional bit
      // (example for 4-bit word: 0011 + 1 = 0100, we had 2 bits, now we have 3).
      //
      // Step 1: Find word that swallows '+1'
      // We do not have to do full 2 complement here (it would require allocation),
      // because there is a faster way:
      // What we actually need is to find the word that swallows this '+1' after
      // the inversion. Basically all of the numbers do this except for the word
      // that has all bits set to 1 (example for 4-bit word: 1111 + 1 = 1 0000).
      // So… inverse of which number has all bits set to '1'? Well… '0'!
      // let indexWhichSwallowsPlus1 = self.storage.firstIndex { $0 != 0 } ?? nope
      //
      // Step 2: If it was not the last word
      // If one of our 'inner words' swallowed '1' then we definitely do not need
      // additional bit. We can just simply invert 'last' and use it as 2 complement:
      //   let complement = ~last
      //   let leadingZeroBitCount = complement.leadingZeroBitCount
      //   return wordsWidth - leadingZeroBitCount
      //
      // Step 3: If 'last' is the one that handles '+1' then we may need additional bit
      // Our last word will handle '+1', we can calculate full 2 complement in place:
      //   let inverted = ~last
      //   let complement = inverted + 1 // Will not overflow, because we checked for 0
      // Now we are in the exactly same same place as 'smi':
      //   let oneAsSign = 1
      //   let complementLeadingOneBitCount = (~complement).leadingZeroBitCount
      //   return wordsWidth - complementLeadingOneBitCount + oneAsSign
    }
  }

  // MARK: - Words

  // Some parts of this code were taken from:
  // https://github.com/attaswift/BigInt
  //
  // Remember that for '0' we have to return single '0' word,
  // even though 'BigIntHeap' is empty.
  public struct Words: RandomAccessCollection {

    private let _heap: BigInt
    private let _count: Int
    private let _decrementLimit: Int

    fileprivate init(_ heap: BigInt) {
      self._heap = heap

      let bitWidth = heap.bitWidth
      let (q, r) = bitWidth.quotientAndRemainder(dividingBy: Word.bitWidth)
      let signWord = r == 0 ? 0 : 1 // This also handles additional word for '0'
      self._count = q + signWord

      switch heap.isPositiveOrZero {
      case true:
        self._decrementLimit = 0
      case false:
        // To do 2 complement for negative numbers we need to invert and add '1'.
        // '0' after inverse is '1111', so by adding '1' we overflow.
        // We look for first non 0, so that we know at which word we need to stop adding.
        self._decrementLimit = heap.storage.withWordsBuffer { words in
          return words.firstIndex { $0 != 0 } ?? Int.min
        }

        assert(self._decrementLimit != Int.min, "Unexpected all words 0")
      }
    }

    public var startIndex: Int {
      return 0
    }

    public var endIndex: Int {
      return self._count
    }

    public subscript(_ index: Int) -> UInt {
      precondition(0 <= index && index < self._count, "Index out or bounds")

      let isSignWord = index >= self._heap.storage.count
      if isSignWord {
        // Sign extension
        let allOnes = Word.max
        return self._heap.isPositiveOrZero ? 0 : allOnes
      }

      return self._heap.storage.withWordsBuffer { words in
        let word = words[index]

        if self._heap.isPositiveOrZero {
          return word
        }

        if index <= self._decrementLimit {
          // If the 'word' was '0' then 'word &- 1' is 'max'
          return ~(word &- 1)
        }

        return ~word
      }
    }
  }

  /// A collection containing the words of this value’s binary representation,
  /// in order from the least significant to most significant.
  public var words: Words {
    return Words(self)
  }

  // MARK: - Trailing zero bit count

  public var trailingZeroBitCount: Int {
    return self.storage.withWordsBuffer { words in
      for (index, word) in words.enumerated() {
        if word != 0 { // swiftlint:disable:this for_where
          return index * Word.bitWidth + word.trailingZeroBitCount
        }
      }

      assert(self.isZero)
      return trailingZeroBitCountForZero
    }
  }
}

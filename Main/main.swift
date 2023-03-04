import BigInt

// Adapted from:
// https://github.com/apple/swift-numerics/pull/120 by Xiaodi Wu (xwu)
func π(count: Int) {
  var acc: BigInt = 0
  var num: BigInt = 1
  var den: BigInt = 1

  func extractDigit(_ n: UInt) -> UInt {
    var tmp = num * BigInt(n)
    tmp += acc
    tmp /= den
    return tmp.words[0]
  }

  func eliminateDigit(_ d: UInt) {
    acc -= den * BigInt(d)
    acc *= 10
    num *= 10
  }

  func nextTerm(_ k: UInt) {
    let k2 = BigInt(k * 2 + 1)
    acc += num * 2
    acc *= k2
    den *= k2
    num *= BigInt(k)
  }

  var i = 0
  var k = 0 as UInt
  var string = ""
  while i < count {
    k += 1
    nextTerm(k)
    if num > acc { continue }
    let d = extractDigit(3)
    if d != extractDigit(4) { continue }
    string.append("\(d)")
    i += 1
    if i.isMultiple(of: 10) {
      print("\(string)\t:\(i)")
      string = ""
    }
    eliminateDigit(d)
  }
}

for _ in 0...10 {
  π(count: 5000)
}

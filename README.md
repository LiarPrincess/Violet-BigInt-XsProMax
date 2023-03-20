`BigInt` implementation from [Violet - Python VM written in Swift](https://github.com/LiarPrincess/Violet/tree/swift-numerics) with following changes:

- no small inlined integer (`Smi`) - magnitude is always stored on the heap
- no restrictions on the size - `isNegative` is stored in-line (and not on the heap like in Violet); `count` and `capacity` are on the heap because I don't want to stray too much from `Violet`.

Which gives us:

```Swift
struct BigInt {
  struct Header {
    var count: UInt32
    var capacity: UInt32
  }

  var flags: UInt8
  var buffer: ManagedBufferPointer<Header, UInt>
}
```

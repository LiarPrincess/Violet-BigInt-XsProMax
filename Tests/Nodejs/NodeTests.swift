//===--- NodeTests.swift --------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
import BigInt

/// Tests generated by Node.js.
///
/// We could have used some other BigInt library (for example GMP),
/// but this is a bit easier to manage.
class NodeTests: XCTestCase {

  // MARK: - Unary operations

  internal func plusTest(value: String,
                         expecting: String,
                         file: StaticString = #file,
                         line: UInt = #line) {
    self.unaryOp(value: value,
                 expecting: expecting,
                 op: { +$0 },
                 file: file,
                 line: line)
  }

  internal func minusTest(value: String,
                          expecting: String,
                          file: StaticString = #file,
                          line: UInt = #line) {
    self.unaryOp(value: value,
                 expecting: expecting,
                 op: { -$0 },
                 file: file,
                 line: line)
  }

  internal func invertTest(value: String,
                           expecting: String,
                           file: StaticString = #file,
                           line: UInt = #line) {
    self.unaryOp(value: value,
                 expecting: expecting,
                 op: { ~$0 },
                 file: file,
                 line: line)
  }

  internal typealias UnaryOperation = (BigInt) -> BigInt

  private func unaryOp(value _value: String,
                       expecting _expected: String,
                       op: UnaryOperation,
                       file: StaticString,
                       line: UInt) {
    guard let value = self.parse(_value, file: file, line: line),
          let expected = self.parse(_expected, file: file, line: line) else {
      return
    }

    let result = op(value)
    XCTAssertEqual(result, expected, file: file, line: line)
  }

  // MARK: - Binary operations

  internal func addTest(lhs: String,
                        rhs: String,
                        expecting: String,
                        file: StaticString = #file,
                        line: UInt = #line) {
    self.binaryOp(lhs: lhs,
                  rhs: rhs,
                  expecting: expecting,
                  op: { $0 + $1 },
                  inoutOp: { $0 += $1 },
                  file: file,
                  line: line)
  }

  internal func subTest(lhs: String,
                        rhs: String,
                        expecting: String,
                        file: StaticString = #file,
                        line: UInt = #line) {
    self.binaryOp(lhs: lhs,
                  rhs: rhs,
                  expecting: expecting,
                  op: { $0 - $1 },
                  inoutOp: { $0 -= $1 },
                  file: file,
                  line: line)
  }

  internal func mulTest(lhs: String,
                        rhs: String,
                        expecting: String,
                        file: StaticString = #file,
                        line: UInt = #line) {
    self.binaryOp(lhs: lhs,
                  rhs: rhs,
                  expecting: expecting,
                  op: { $0 * $1 },
                  inoutOp: { $0 *= $1 },
                  file: file,
                  line: line)
  }

  internal func divTest(lhs: String,
                        rhs: String,
                        expecting: String,
                        file: StaticString = #file,
                        line: UInt = #line) {
    self.binaryOp(lhs: lhs,
                  rhs: rhs,
                  expecting: expecting,
                  op: { $0 / $1 },
                  inoutOp: { $0 /= $1 },
                  file: file,
                  line: line)
  }

  internal func modTest(lhs: String,
                        rhs: String,
                        expecting: String,
                        file: StaticString = #file,
                        line: UInt = #line) {
    self.binaryOp(lhs: lhs,
                  rhs: rhs,
                  expecting: expecting,
                  op: { $0 % $1 },
                  inoutOp: { $0 %= $1 },
                  file: file,
                  line: line)
  }

  internal func andTest(lhs: String,
                        rhs: String,
                        expecting: String,
                        file: StaticString = #file,
                        line: UInt = #line) {
    self.binaryOp(lhs: lhs,
                  rhs: rhs,
                  expecting: expecting,
                  op: { $0 & $1 },
                  inoutOp: { $0 &= $1 },
                  file: file,
                  line: line)
  }

  internal func orTest(lhs: String,
                       rhs: String,
                       expecting: String,
                       file: StaticString = #file,
                       line: UInt = #line) {
    self.binaryOp(lhs: lhs,
                  rhs: rhs,
                  expecting: expecting,
                  op: { $0 | $1 },
                  inoutOp: { $0 |= $1 },
                  file: file,
                  line: line)
  }

  internal func xorTest(lhs: String,
                        rhs: String,
                        expecting: String,
                        file: StaticString = #file,
                        line: UInt = #line) {
    self.binaryOp(lhs: lhs,
                  rhs: rhs,
                  expecting: expecting,
                  op: { $0 ^ $1 },
                  inoutOp: { $0 ^= $1 },
                  file: file,
                  line: line)
  }

  internal typealias BinaryOperation = (BigInt, BigInt) -> BigInt
  internal typealias InoutBinaryOperation = (inout BigInt, BigInt) -> Void

  // swiftlint:disable:next function_parameter_count
  private func binaryOp(lhs _lhs: String,
                        rhs _rhs: String,
                        expecting _expected: String,
                        op: BinaryOperation,
                        inoutOp: InoutBinaryOperation,
                        file: StaticString,
                        line: UInt) {
    guard let lhs = self.parse(_lhs, file: file, line: line),
          let lhsBeforeInout = self.parse(_lhs, file: file, line: line),
          let rhs = self.parse(_rhs, file: file, line: line),
          let expected = self.parse(_expected, file: file, line: line) else {
      return
    }

    // Check 'standard' op
    let result = op(lhs, rhs)
    XCTAssertEqual(result, expected, file: file, line: line)

    // Check 'inout' op
    var inoutLhs = lhs
    inoutOp(&inoutLhs, rhs)
    XCTAssertEqual(inoutLhs, expected, "INOUT!!1", file: file, line: line)

    // Make sure that 'inout' operation did not modify 'lhs'.
    // (COW: they shared a single buffer -> inout should copy it before modification)
    let inoutMsg = "Inout did modify shared/original value"
    XCTAssertEqual(lhs, lhsBeforeInout, inoutMsg, file: file, line: line)
  }

  // MARK: - Div mod

  internal func divModTest(lhs _lhs: String,
                           rhs _rhs: String,
                           div _div: String,
                           mod _mod: String,
                           file: StaticString = #file,
                           line: UInt = #line) {
    guard let lhs = self.parse(_lhs, file: file, line: line),
          let rhs = self.parse(_rhs, file: file, line: line),
          let div = self.parse(_div, file: file, line: line),
          let mod = self.parse(_mod, file: file, line: line) else {
      return
    }

    let result = lhs.quotientAndRemainder(dividingBy: rhs)
    XCTAssertEqual(result.quotient, div, "div", file: file, line: line)
    XCTAssertEqual(result.remainder, mod, "mod", file: file, line: line)
  }

  // MARK: - Power

  internal func powerTest(base _base: String,
                          exponent _exponent: Int,
                          expecting _expected: String,
                          file: StaticString = #file,
                          line: UInt = #line) {
    guard let base = self.parse(_base, file: file, line: line),
          let expected = self.parse(_expected, file: file, line: line) else {
      return
    }

    let exponent = BigInt(_exponent)
    let result = base.power(exponent: exponent)
    XCTAssertEqual(result, expected, file: file, line: line)
  }

  // MARK: - Shifts

  internal func shiftLeftTest(value: String,
                              count: Int,
                              expecting: String,
                              file: StaticString = #file,
                              line: UInt = #line) {
    self.shiftOp(value: value,
                 count: count,
                 expecting: expecting,
                 op: { $0 << $1 },
                 inoutOp: { $0 <<= $1 },
                 file: file,
                 line: line)
  }

  internal func shiftRightTest(value: String,
                               count: Int,
                               expecting: String,
                               file: StaticString = #file,
                               line: UInt = #line) {
    self.shiftOp(value: value,
                 count: count,
                 expecting: expecting,
                 op: { $0 >> $1 },
                 inoutOp: { $0 >>= $1 },
                 file: file,
                 line: line)
  }

  internal typealias ShiftOperation = (BigInt, BigInt) -> BigInt
  internal typealias InoutShiftOperation = (inout BigInt, BigInt) -> Void

  // swiftlint:disable:next function_parameter_count
  private func shiftOp(value _value: String,
                       count _count: Int,
                       expecting _expected: String,
                       op: ShiftOperation,
                       inoutOp: InoutShiftOperation,
                       file: StaticString,
                       line: UInt) {
    guard let value = self.parse(_value, file: file, line: line),
          let valueBeforeInout = self.parse(_value, file: file, line: line),
          let expected = self.parse(_expected, file: file, line: line) else {
      return
    }

    let count = BigInt(_count)

    // Check 'standard' op
    let result = op(value, count)
    XCTAssertEqual(result, expected, file: file, line: line)

    // Check 'inout' op
    var inoutValue = value
    inoutOp(&inoutValue, count)
    XCTAssertEqual(inoutValue, expected, "INOUT!!1", file: file, line: line)

    // Make sure that 'inout' operation did not modify 'lhs'.
    // (COW: they shared a single buffer -> inout should copy it before modification)
    let inoutMsg = "Inout did modify shared/original value"
    XCTAssertEqual(value, valueBeforeInout, inoutMsg, file: file, line: line)
  }

  // MARK: - Helpers

  /// Abstraction over `BigInt(_:radix:)`.
  private func parse(_ string: String, file: StaticString, line: UInt) -> BigInt? {
    if let n = BigInt(string, radix: 10) {
      return n
    }

    XCTFail("Unable to parse '\(string)'.", file: file, line: line)
    return nil
  }
}

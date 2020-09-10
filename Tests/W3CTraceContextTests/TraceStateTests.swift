//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift W3C Trace Context open source project
//
// Copyright (c) 2020 Moritz Lang and the Swift W3C Trace Context project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

@testable import W3CTraceContext
import XCTest

final class TraceStateTests: XCTestCase {
    // MARK: - Equality

    func testNotEqualIfStorageCountDiffers() {
        let lhs = TraceState([("rojo", "00f067aa0ba902b7")])
        let rhs = TraceState([("rojo", "00f067aa0ba902b7"), ("congo", "t61rcWkgMzE")])

        XCTAssertNotEqual(lhs, rhs)
    }

    func testNotEqualIfStorageOrderDiffers() {
        let lhs = TraceState([("congo", "t61rcWkgMzE"), ("rojo", "00f067aa0ba902b7")])
        let rhs = TraceState([("rojo", "00f067aa0ba902b7"), ("congo", "t61rcWkgMzE")])

        XCTAssertNotEqual(lhs, rhs)
    }

    // MARK: - Encoding

    func testEncodeEmptyTraceState() {
        XCTAssertEqual(TraceState([]).rawValue, "")
    }

    func testEncodeNonEmptyTraceState() {
        let traceStateRawValue = "rojo=00f067aa0ba902b7,congo=t61rcWkgMzE"
        let traceState = TraceState(rawValue: traceStateRawValue)

        XCTAssertEqual(traceState?.rawValue, traceStateRawValue)
    }

    func testDescriptionUsesRawValue() {
        let traceStateRawValue = "rojo=00f067aa0ba902b7,congo=t61rcWkgMzE"
        let traceState = TraceState(rawValue: traceStateRawValue)

        XCTAssertEqual(String(describing: traceState!), traceStateRawValue)
    }

    // MARK: - Decoding

    func testInitValidRawValue() {
        let traceState = TraceState(rawValue: "rojo=00f067aa0ba902b7,congo=t61rcWkgMzE")

        XCTAssertEqual(traceState, TraceState([("rojo", "00f067aa0ba902b7"), ("congo", "t61rcWkgMzE")]))
    }

    func testInitWithMultitenantRawValue() {
        let traceState = TraceState(rawValue: "fw529a3039@dt=00f067aa0ba902b7")

        XCTAssertEqual(traceState, TraceState([("fw529a3039@dt", "00f067aa0ba902b7")]))
    }

    func testInitWithInvalidCharacterInKey() {
        XCTAssertNil(TraceState(rawValue: "ROJO=00f067aa0ba902b7"))
    }

    func testInitEmptyRawValue() {
        XCTAssertEqual(TraceState(rawValue: ""), TraceState([]))
    }

    func testInitWithTooLongKey() {
        XCTAssertNil(TraceState(rawValue: String(repeating: "1", count: 257) + "=t61rcWkgMzE"))
    }

    func testInitWithKeyEndingWithAtSign() {
        XCTAssertNil(TraceState(rawValue: "rojo@=00f067aa0ba902b7"))
    }

    func testInitRawValueWithoutKey() {
        XCTAssertNil(TraceState(rawValue: "rojo=00f067aa0ba902b7,=t61rcWkgMzE"))
    }

    func testInitRawValueEmptyValue() {
        let traceState = TraceState(rawValue: "rojo=,congo=t61rcWkgMzE")

        XCTAssertEqual(traceState, TraceState([
            ("rojo", ""),
            ("congo", "t61rcWkgMzE"),
        ]))
    }

    func testInitRawValueWhitespace() {
        let traceState = TraceState(rawValue: #"       rojo=00f067aa0ba902b7  ,\#tcongo=t61rcWkgMzE    "#)

        XCTAssertEqual(traceState, TraceState([
            ("rojo", "00f067aa0ba902b7"),
            ("congo", "t61rcWkgMzE"),
        ]))
    }

    func testInitWhitespaceOnly() {
        XCTAssertEqual(TraceState(rawValue: "\t\t\t   "), TraceState([]))
    }
}

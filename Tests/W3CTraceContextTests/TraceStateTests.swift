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
    // MARK: - Creation

    func test_create_empty_trace_state() {
        XCTAssertEqual(TraceState.none.rawValue, "")
    }

    // MARK: - Equality

    func test_equal_sameStorage() {
        let lhs = TraceState([("rojo", "00f067aa0ba902b7"), ("congo", "t61rcWkgMzE")])
        let rhs = TraceState([("rojo", "00f067aa0ba902b7"), ("congo", "t61rcWkgMzE")])

        XCTAssertEqual(lhs, rhs)
    }

    func test_not_equal_storageCountDiffers() {
        let lhs = TraceState([("rojo", "00f067aa0ba902b7")])
        let rhs = TraceState([("rojo", "00f067aa0ba902b7"), ("congo", "t61rcWkgMzE")])

        XCTAssertNotEqual(lhs, rhs)
    }

    func test_not_equal_storageOrderDiffers() {
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

    func testInitRawValueValidRawValue() {
        let traceState = TraceState(rawValue: "rojo=00f067aa0ba902b7,congo=t61rcWkgMzE")

        XCTAssertEqual(traceState, TraceState([("rojo", "00f067aa0ba902b7"), ("congo", "t61rcWkgMzE")]))
    }

    func testInitRawValueWithMultitenantRawValue() {
        let traceState = TraceState(rawValue: "fw529a3039@dt=00f067aa0ba902b7")

        XCTAssertEqual(traceState, TraceState([("fw529a3039@dt", "00f067aa0ba902b7")]))
    }

    func testInitRawValueWithInvalidCharacterInKey() {
        XCTAssertNil(TraceState(rawValue: "ROJO=00f067aa0ba902b7"))
    }

    func testInitRawValueEmptyRawValue() {
        XCTAssertEqual(TraceState(rawValue: ""), TraceState([]))
    }

    func testInitRawValueWithTooLongKey() {
        XCTAssertNil(TraceState(rawValue: String(repeating: "1", count: 257) + "=t61rcWkgMzE"))
    }

    func testInitRawValueWithKeyEndingWithAtSign() {
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

    func testInitRawValueWhitespaceOnly() {
        XCTAssertEqual(TraceState(rawValue: "\t\t\t   "), TraceState([]))
    }
}

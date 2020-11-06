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

final class TraceIDTests: XCTestCase {
    // MARK: - Decoding

    func test_decodingFromHexString_succeeds() throws {
        let high: UInt64 = 9_532_127_138_774_266_268
        let low: UInt64 = 790_211_418_057_950_173
        let hexString = high.paddedHexString(radix: 16) + low.paddedHexString(radix: 16)

        let traceID = try XCTUnwrap(TraceID(hexString: hexString))
        XCTAssertEqual(traceID.high, high)
        XCTAssertEqual(traceID.low, low)
    }

    func test_decodingFromHexString_fails_invalidHex() {
        XCTAssertNil(TraceID(hexString: "THIRTY_TWO_INVALID_HEXCHARACTERS"))
    }

    func test_decodingFromHexString_fails_invalidHighHex() {
        XCTAssertNil(TraceID(hexString: "INVALIDHIGHERHEXbd75781e8c42f2c1"))
    }

    func test_decodingFromHexString_fails_invalidLowHex() {
        XCTAssertNil(TraceID(hexString: "bd75781e8c42f2c1_INVALIDLOWERHEX"))
    }

    func test_decodingFromHexString_fails_tooShort() {
        XCTAssertNil(TraceID(hexString: "tooshort"))
    }

    func test_decodingFromHexString_fails_allZeros() {
        XCTAssertNil(TraceID(hexString: String(repeating: "0", count: 16)))
    }

    // MARK: - Encoding

    func test_encodingToHexString_succeeds() {
        let traceID = TraceID(high: .max, low: .max)

        XCTAssertEqual(String(describing: traceID), "ffffffffffffffffffffffffffffffff")
    }

    func test_encodingToHexString_padsLeadingZeros() {
        let traceID = TraceID(high: 256, low: 256)

        XCTAssertEqual(String(describing: traceID), "00000000000001000000000000000100")
    }

    // MARK: - Equality

    func test_equatingTraceIDs_succeeds() {
        let traceID = TraceID(high: 1, low: 1)

        XCTAssertEqual(traceID, TraceID(high: 1, low: 1))
        XCTAssertNotEqual(traceID, TraceID(high: 2, low: 1))
        XCTAssertNotEqual(traceID, TraceID(high: 1, low: 2))
        XCTAssertNotEqual(traceID, TraceID(high: 2, low: 2))
    }

    // MARK: - Comparison

    func test_comparingTraceIDs_succeeds() {
        XCTAssertGreaterThan(TraceID(high: 3, low: 3), TraceID(high: 2, low: 2))
        XCTAssertGreaterThan(TraceID(high: 2, low: 3), TraceID(high: 2, low: 2))
        XCTAssertGreaterThan(TraceID(high: 2, low: 2), TraceID(high: 1, low: 1))
        XCTAssertGreaterThan(TraceID(high: 2, low: 2), TraceID(high: 2, low: 1))
    }

    // MARK: - Randomness

    func test_generatingRandomTraceID_succeeds_usingSystemNumberGenerator() {
        let traceID = TraceID.random()

        // must always be greater than 0 to be valid
        XCTAssertGreaterThan(traceID.high, 0)
        XCTAssertGreaterThan(traceID.low, 0)
    }

    func test_generatingRandomTraceID_succeeds_usingTestNumberGenerator() {
        var generator = TestRandomNumberGenerator(queue: [1, 2])

        let traceID = TraceID.random(using: &generator)
        XCTAssertEqual(traceID, TraceID(high: 1, low: 2))
    }
}

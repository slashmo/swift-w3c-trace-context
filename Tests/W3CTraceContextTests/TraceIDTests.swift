//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift W3C TraceContext open source project
//
// Copyright (c) 2024 Moritz Lang and the Swift W3C TraceContext project
// authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import W3CTraceContext
import XCTest

final class TraceIDTests: XCTestCase {
    func test_bytes_returnsSixteenByteArrayRepresentation() {
        let traceID = TraceID.oneToSixteen

        XCTAssertEqual(Array(traceID), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16])
    }

    func test_equatableConformance() {
        let traceID1 = TraceID(bytes: (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16))
        let traceID2 = TraceID(bytes: (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0))

        XCTAssertEqual(traceID1, traceID1)
        XCTAssertEqual(traceID2, traceID2)
        XCTAssertNotEqual(traceID1, traceID2)
    }

    func test_identifiableConformance() {
        let randomTraceIDs = (0 ..< 100).map { _ in TraceID.random().id }

        XCTAssertEqual(Set(randomTraceIDs).count, 100)
    }

    func test_description_returnsHexStringRepresentation() {
        let traceID = TraceID(bytes: (0, 10, 20, 30, 40, 60, 80, 100, 120, 140, 160, 180, 200, 220, 240, 255))

        XCTAssertEqual("\(traceID)", "000a141e283c5064788ca0b4c8dcf0ff")
    }

    func test_random_withCustomNumberGenerator_usesBytesFromRandomNumbers() {
        var generator = IncrementingRandomNumberGenerator()

        let traceID1 = TraceID.random(using: &generator)
        XCTAssertEqual(traceID1, TraceID(bytes: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)))

        let traceID2 = TraceID.random(using: &generator)
        XCTAssertEqual(traceID2, TraceID(bytes: (0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 3)))
    }

    func test_random_withDefaultNumberGenerator_returnsRandomSpanIDs() {
        let randomTraceIDs = (0 ..< 100).map { _ in TraceID.random() }

        XCTAssertEqual(Set(randomTraceIDs).count, 100)
    }
}

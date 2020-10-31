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

final class TraceParentRawRepresentableTests: XCTestCase {
    // MARK: - Encoding

    func testEncodesToValidRawValue() {
        let traceParent = TraceParent(
            traceID: "0af7651916cd43dd8448eb211c80319c",
            parentID: "b7ad6b7169203331",
            traceFlags: .sampled
        )

        XCTAssertEqual(traceParent.rawValue, "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01")
    }

    // MARK: - Decoding

    func testDecodeValidTraceParentStringWithSampledFlag() {
        let rawValue = "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
        guard let traceParent = TraceParent(rawValue: rawValue) else {
            XCTFail("Could not decode valid trace parent")
            return
        }

        XCTAssertEqual(
            traceParent,
            TraceParent(traceID: "0af7651916cd43dd8448eb211c80319c", parentID: "b7ad6b7169203331", traceFlags: .sampled)
        )
    }

    func testDecodeValidTraceParentStringWithUnsupportedTraceFlags() {
        let rawValue = "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-11"
        guard let traceParent = TraceParent(rawValue: rawValue) else {
            XCTFail("Could not decode valid trace parent")
            return
        }

        XCTAssertEqual(
            traceParent,
            TraceParent(traceID: "0af7651916cd43dd8448eb211c80319c", parentID: "b7ad6b7169203331", traceFlags: [])
        )
    }

    func testDecodeValidTraceParentStringWithoutSampledFlag() {
        let rawValue = "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-00"
        guard let traceParent = TraceParent(rawValue: rawValue) else {
            XCTFail("Could not decode valid trace parent")
            return
        }

        XCTAssertEqual(
            traceParent,
            TraceParent(traceID: "0af7651916cd43dd8448eb211c80319c", parentID: "b7ad6b7169203331", traceFlags: [])
        )

        XCTAssertFalse(traceParent.traceFlags.contains(.sampled))
    }

    func testDecodeFailsWithTooLongRawValue() {
        let rawValue = String(repeating: "42", count: 1000)
        XCTAssertUninitializedTraceParent(rawValue)
    }

    func testDecodeFailsWithTooShortRawValue() {
        let rawValue = "too-short"
        XCTAssertUninitializedTraceParent(rawValue)
    }

    func testDecodeFailsWithTooManyComponents() {
        let rawValue = "00-0af7651916cd43dd8448eb211c803-b7ad6b7169203331-01-12"
        XCTAssertUninitializedTraceParent(rawValue)
    }

    func testDecodeFailsWithTooFewComponents() {
        let rawValue = "00-0af7651916cd43dd8448eb211c803-b7ad6b7169203331000000"
        XCTAssertUninitializedTraceParent(rawValue)
    }

    func testDecodeFailsWithInvalidVersionComponent() {
        let rawValue = "ff-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
        XCTAssertUninitializedTraceParent(rawValue)
    }

    func testDecodeFailsWithTooLongTraceID() {
        let rawValue = "00-0af7651916cd43dd8448eb211c80319cclearlylongerthan16bytes-b7ad6b7169203331-01"
        XCTAssertUninitializedTraceParent(rawValue)
    }

    func testDecodeFailsWithTooShortTraceID() {
        let rawValue = "00-tooshort-b7ad6b7169203331-01432436432435434234234234"
        XCTAssertUninitializedTraceParent(rawValue)
    }

    func testDecodeFailsWithAllZeroesTraceID() {
        let rawValue = "00-00000000000000000000000000000000-b7ad6b7169203331-01"
        XCTAssertUninitializedTraceParent(rawValue)
    }

    func testDecodeFailsWithTooShortParentID() {
        let rawValue = "00-0af7651916cd43dd8448eb211c80319c-tooshort-0131434343"
        XCTAssertUninitializedTraceParent(rawValue)
    }

    func testDecodeFailsWithAllZeroesParentID() {
        let rawValue = "00-0af7651916cd43dd8448eb211c80319c-0000000000000000-01"
        XCTAssertUninitializedTraceParent(rawValue)
    }

    func testDecodeFailsWithTooLongTraceFlags() {
        let rawValue = "00-0af7651916cd43dd8448eb211c80319c-b7ad6b71692-toolong"
        XCTAssertUninitializedTraceParent(rawValue)
    }

    func testDecodeFailsWithTooShortTraceFlags() {
        let rawValue = "00-0af7651916cd43dd8448eb211c80319c-b7ad6b71692033311-0"
        XCTAssertUninitializedTraceParent(rawValue)
    }

    // MARK: - Equatable

    func testNonEqualTraceID() {
        let parent1 = TraceParent(rawValue: "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01")
        let parent2 = TraceParent(rawValue: "00-12345678912345678912345678912345-b7ad6b7169203331-01")

        XCTAssertNotNil(parent1)
        XCTAssertNotNil(parent2)

        XCTAssertNotEqual(parent1, parent2)
    }

    func testNonEqualParentID() {
        let parent1 = TraceParent(rawValue: "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01")
        let parent2 = TraceParent(rawValue: "00-0af7651916cd43dd8448eb211c80319c-1234567891234567-01")

        XCTAssertNotNil(parent1)
        XCTAssertNotNil(parent2)

        XCTAssertNotEqual(parent1, parent2)
    }

    func testNonEqualTraceFlags() {
        let parent1 = TraceParent(rawValue: "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-00")
        let parent2 = TraceParent(rawValue: "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01")

        XCTAssertNotNil(parent1)
        XCTAssertNotNil(parent2)

        XCTAssertNotEqual(parent1, parent2)
    }

    // MARK: - Random

    func test_generate_random_traceParent() {
        let traceParent = TraceParent.random()

        // validate random trace-parent by parsing its raw value
        XCTAssertEqual(TraceParent(rawValue: traceParent.rawValue), traceParent)
    }
}

private func XCTAssertUninitializedTraceParent(_ rawValue: String, file: StaticString = #file, line: UInt = #line) {
    if let traceParent = TraceParent(rawValue: rawValue) {
        XCTFail(
            "Expected trace parent not to be initialized from invalid raw value: \(traceParent)",
            file: file,
            line: line
        )
    }
}

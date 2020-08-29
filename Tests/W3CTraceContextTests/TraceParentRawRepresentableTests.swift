//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift W3C Trace Context open source project
//
// Copyright (c) YEARS Moritz Lang and the Swift W3C Trace Context project authors
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
    // MARK: - Trace Parent -

    func testDecodeValidTraceParentStringWithSampledFlag() {
        let rawValue = "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
        guard let traceParent = W3C.TraceParent(rawValue: rawValue) else {
            XCTFail("Could not decode valid trace parent")
            return
        }

        XCTAssertEqual(
            traceParent,
            W3C.TraceParent(traceID: "0af7651916cd43dd8448eb211c80319c", parentID: "b7ad6b7169203331", traceFlags: "01")
        )

        XCTAssert(traceParent.sampled)
    }

    func testDecodeValidTraceParentStringWithoutSampledFlag() {
        let rawValue = "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-00"
        guard let traceParent = W3C.TraceParent(rawValue: rawValue) else {
            XCTFail("Could not decode valid trace parent")
            return
        }

        XCTAssertEqual(
            traceParent,
            W3C.TraceParent(traceID: "0af7651916cd43dd8448eb211c80319c", parentID: "b7ad6b7169203331", traceFlags: "00")
        )

        XCTAssertFalse(traceParent.sampled)
    }

    func testEncodesToValidRawValue() {
        let traceParent = W3C.TraceParent(
            traceID: "0af7651916cd43dd8448eb211c80319c",
            parentID: "b7ad6b7169203331",
            traceFlags: "01"
        )

        XCTAssertEqual(traceParent.rawValue, "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01")
    }

    func testDecodeFailsWithTooManyComponents() {
        let rawValue = "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01-additional-components"
        XCTAssertUninitializedTraceParent(rawValue)
    }

    func testDecodeFailsWithTooFewComponents() {
        let rawValue = "00-0af7651916cd43dd8448eb211c80319c"
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
        let rawValue = "00-tooshort-b7ad6b7169203331-01"
        XCTAssertUninitializedTraceParent(rawValue)
    }

    func testDecodeFailsWithAllZeroesTraceID() {
        let rawValue = "00-00000000000000000000000000000000-b7ad6b7169203331-01"
        XCTAssertUninitializedTraceParent(rawValue)
    }

    func testDecodeFailsWithTooShortParentID() {
        let rawValue = "00-0af7651916cd43dd8448eb211c80319c-tooshort-01"
        XCTAssertUninitializedTraceParent(rawValue)
    }

    func testDecodeFailsWithAllZeroesParentID() {
        let rawValue = "00-0af7651916cd43dd8448eb211c80319c-0000000000000000-01"
        XCTAssertUninitializedTraceParent(rawValue)
    }

    func testDecodeFailsWithTooLongTraceFlags() {
        let rawValue = "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-toolong"
        XCTAssertUninitializedTraceParent(rawValue)
    }

    func testDecodeFailsWithTooShortTraceFlags() {
        let rawValue = "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-0"
        XCTAssertUninitializedTraceParent(rawValue)
    }

    // TODO: Trace State
}

private func XCTAssertUninitializedTraceParent(_ rawValue: String, file: StaticString = #file, line: UInt = #line) {
    if let traceParent = W3C.TraceParent(rawValue: rawValue) {
        XCTFail(
            "Expected trace parent not to be initialized from invalid raw value: \(traceParent)",
            file: file,
            line: line
        )
    }
}

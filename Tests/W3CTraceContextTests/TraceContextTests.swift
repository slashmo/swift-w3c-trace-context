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

final class TraceContextTests: XCTestCase {
    func testInitWithValidRawValues() {
        let traceParentRawValue = "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
        let traceStateRawValue = "rojo=00f067aa0ba902b7"

        guard let traceContext = TraceContext(parent: traceParentRawValue, state: traceStateRawValue) else {
            XCTFail("Could not decode valid trace context")
            return
        }

        XCTAssertEqual(
            traceContext,
            TraceContext(
                parent: TraceParent(
                    traceID: "0af7651916cd43dd8448eb211c80319c",
                    parentID: "b7ad6b7169203331",
                    traceFlags: "01"
                ),
                state: TraceState([("rojo", "00f067aa0ba902b7")])
            )
        )
    }

    func testInitWithInvalidTraceParent() {
        XCTAssertNil(TraceContext(parent: "invalid", state: ""))
    }

    func testInitWithValidTraceParentAndInvalidTraceState() {
        let traceParentRawValue = "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"

        guard let traceContext = TraceContext(parent: traceParentRawValue, state: "invalid") else {
            XCTFail("Could not decode valid trace context")
            return
        }

        XCTAssertEqual(
            traceContext,
            TraceContext(
                parent: TraceParent(
                    traceID: "0af7651916cd43dd8448eb211c80319c",
                    parentID: "b7ad6b7169203331",
                    traceFlags: "01"
                ),
                state: TraceState([])
            )
        )
    }
}

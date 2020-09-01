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

import W3CTraceContext
import XCTest

final class TraceContextTests: XCTestCase {
    func testInitWithValidRawValues() {
        let traceParentRawValue = "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"

        guard let traceContext = W3C.TraceContext(parent: traceParentRawValue) else {
            XCTFail("Could not decode valid trace context")
            return
        }

        XCTAssertEqual(
            traceContext,
            W3C.TraceContext(
                parent: W3C.TraceParent(
                    traceID: "0af7651916cd43dd8448eb211c80319c",
                    parentID: "b7ad6b7169203331",
                    traceFlags: "01"
                )
            )
        )
    }

    func testInitWithInvalidTraceParent() {
        XCTAssertNil(W3C.TraceContext(parent: "invalid"))
    }
}

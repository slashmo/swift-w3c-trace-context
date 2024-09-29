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

final class TraceContextTests: XCTestCase {
    func test_decodingHeaderValues_withValidTraceParentHeader_returnsDecodedTraceContext() throws {
        let traceContext = try TraceContext(
            traceParentHeaderValue: "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
        )

        XCTAssertEqual(traceContext, TraceContext(
            traceID: TraceID(bytes: .init((10, 247, 101, 25, 22, 205, 67, 221, 132, 72, 235, 33, 28, 128, 49, 156))),
            spanID: SpanID(bytes: .init((183, 173, 107, 113, 105, 32, 51, 49))),
            flags: .sampled,
            state: TraceState()
        ))
    }

    func test_decodingHeaderValues_withValidTraceParentAndTraceStateHeaders_returnsDecodedTraceContext() throws {
        let traceContext = try TraceContext(
            traceParentHeaderValue: "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01",
            traceStateHeaderValue: "foo=bar,tenant1@system=1,tenant2@system=2"
        )

        XCTAssertEqual(traceContext, TraceContext(
            traceID: TraceID(bytes: .init((10, 247, 101, 25, 22, 205, 67, 221, 132, 72, 235, 33, 28, 128, 49, 156))),
            spanID: SpanID(bytes: .init((183, 173, 107, 113, 105, 32, 51, 49))),
            flags: .sampled,
            state: TraceState([
                (.simple("foo"), "bar"),
                (.tenant("tenant1", in: "system"), "1"),
                (.tenant("tenant2", in: "system"), "2"),
            ])
        ))
    }

    func test_decodingHeaderValues_withInvalidLength_throwsDecodingError() throws {
        do {
            let traceContext = try TraceContext(traceParentHeaderValue: String(repeating: "🏎️", count: 100))
            XCTFail("Expected decoding error, decoded trace context: \(traceContext)")
        } catch let error as TraceParentDecodingError {
            XCTAssertEqual(error.reason, .invalidTraceParentLength(100))
        }
    }

    func test_decodingHeaderValues_withUnsupportedVersion_throwsDecodingError() throws {
        do {
            let traceContext = try TraceContext(
                traceParentHeaderValue: "01-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
            )
            XCTFail("Expected decoding error, decoded trace context: \(traceContext)")
        } catch let error as TraceParentDecodingError {
            XCTAssertEqual(error.reason, .unsupportedVersion("01"))
        }
    }

    func test_decodingHeaderValues_withInvalidDelimiters_throwsDecodingError() throws {
        do {
            let traceContext = try TraceContext(
                traceParentHeaderValue: "00_0af7651916cd43dd8448eb211c80319c+b7ad6b7169203331!01"
            )
            XCTFail("Expected decoding error, decoded trace context: \(traceContext)")
        } catch let error as TraceParentDecodingError {
            XCTAssertEqual(error.reason, .invalidDelimiters)
        }
    }

    func test_decodingHeaderValues_withAllZeroesTraceID_throwsDecodingError() throws {
        do {
            let traceContext = try TraceContext(
                traceParentHeaderValue: "00-00000000000000000000000000000000-b7ad6b7169203331-01"
            )
            XCTFail("Expected decoding error, decoded trace context: \(traceContext)")
        } catch let error as TraceParentDecodingError {
            XCTAssertEqual(error.reason, .invalidTraceID("00000000000000000000000000000000"))
        }
    }

    func test_decodingHeaderValues_withAllZeroesSpanID_throwsDecodingError() throws {
        do {
            let traceContext = try TraceContext(
                traceParentHeaderValue: "00-0af7651916cd43dd8448eb211c80319c-0000000000000000-01"
            )
            XCTFail("Expected decoding error, decoded trace context: \(traceContext)")
        } catch let error as TraceParentDecodingError {
            XCTAssertEqual(error.reason, .invalidSpanID("0000000000000000"))
        }
    }

    func test_traceParentHeaderValue_withSampledFlag() {
        let traceContext = TraceContext(
            traceID: .oneToSixteen,
            spanID: .oneToEight,
            flags: .sampled,
            state: TraceState()
        )

        XCTAssertEqual(traceContext.traceParentHeaderValue, "00-0102030405060708090a0b0c0d0e0f10-0102030405060708-01")
    }

    func test_traceParentHeaderValue_withoutSampledFlag() {
        let traceContext = TraceContext(
            traceID: .oneToSixteen,
            spanID: .oneToEight,
            flags: [],
            state: TraceState()
        )

        XCTAssertEqual(traceContext.traceParentHeaderValue, "00-0102030405060708090a0b0c0d0e0f10-0102030405060708-00")
    }

    func test_traceStateHeaderValue_withEmptyTraceState_returnsNil() {
        let traceContext = TraceContext(
            traceID: .oneToSixteen,
            spanID: .oneToEight,
            flags: [],
            state: TraceState()
        )

        XCTAssertNil(traceContext.traceStateHeaderValue)
    }

    func test_traceStateHeaderValue_withSingleTraceStateEntryWithSimpleVendor() {
        let traceContext = TraceContext(
            traceID: .oneToSixteen,
            spanID: .oneToEight,
            flags: [],
            state: TraceState([(.simple("vendor"), "value")])
        )

        XCTAssertEqual(traceContext.traceStateHeaderValue, "vendor=value")
    }

    func test_traceStateHeaderValue_withSingleTraceStateEntryWithMultitenantVendor() {
        let traceContext = TraceContext(
            traceID: .oneToSixteen,
            spanID: .oneToEight,
            flags: [],
            state: TraceState([(.tenant("tenant", in: "system"), "value")])
        )

        XCTAssertEqual(traceContext.traceStateHeaderValue, "tenant@system=value")
    }

    func test_traceStateHeaderValue_withMultipleTraceStateEntries() {
        let traceContext = TraceContext(
            traceID: .oneToSixteen,
            spanID: .oneToEight,
            flags: [],
            state: TraceState([
                (.simple("system"), "value1"),
                (.tenant("tenant", in: "system"), "value2"),
            ])
        )

        XCTAssertEqual(traceContext.traceStateHeaderValue, "system=value1, tenant@system=value2")
    }
}

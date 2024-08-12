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

/// Context of a single span within a distributed trace.
///
/// Serializing and propagating this context across asynchronous boundaries (e.g. via HTTP headers)
/// enables _distributed_ tracing, allowing a trace to be comprised of spans that exist on different nodes of a distributed system.
///
/// [W3C TraceContext](https://www.w3.org/TR/trace-context-1/)
public struct TraceContext: Sendable {
    /// The unique ID of the trace this span belongs to.
    public let traceID: TraceID

    /// The unique ID of this span.
    public let spanID: SpanID

    /// The tracing flags for this span, e.g. whether it's sampled.
    public let flags: TraceFlags

    /// Vendor-specific string values to be propagated alongside this span.
    public var state: TraceState

    /// Create a trace context for a span manually with the given values.
    ///
    /// - Parameters:
    ///   - traceID: The unique ID of the trace this span belongs to.
    ///   - spanID: The unique ID of this span.
    ///   - flags: The trace flags for this span.
    ///   - state: Vendor-specific string values to be propagated alongside this span.
    public init(traceID: TraceID, spanID: SpanID, flags: TraceFlags, state: TraceState) {
        self.traceID = traceID
        self.spanID = spanID
        self.flags = flags
        self.state = state
    }

    /// Create a trace context by decoding the given header values.
    ///
    /// - Parameters:
    ///   - traceParentHeaderValue: The value of the `traceparent` header.
    ///   - traceStateHeaderValue: The value of the optional `tracestate` header.
    public init(traceParentHeaderValue: String, traceStateHeaderValue: String? = nil) throws {
        let traceParent = Array(traceParentHeaderValue.utf8)

        guard traceParent.count == 55 else {
            throw TraceParentDecodingError(.invalidTraceParentLength(traceParentHeaderValue.count))
        }

        // version
        guard traceParent[0] == 48, traceParent[1] == 48 else {
            let version = String(decoding: traceParent[0 ... 1], as: UTF8.self)
            throw TraceParentDecodingError(.unsupportedVersion(version))
        }

        guard traceParent[2] == 45, traceParent[35] == 45, traceParent[52] == 45 else {
            throw TraceParentDecodingError(.invalidDelimiters)
        }

        // trace ID

        var traceIDBytes = TraceID.Bytes(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        withUnsafeMutableBytes(of: &traceIDBytes) { ptr in
            Hex.convert(traceParent[3 ..< 35], toBytes: ptr)
        }
        if traceIDBytes._bytes.0 == 0,
           traceIDBytes._bytes.1 == 0,
           traceIDBytes._bytes.2 == 0,
           traceIDBytes._bytes.3 == 0,
           traceIDBytes._bytes.4 == 0,
           traceIDBytes._bytes.5 == 0,
           traceIDBytes._bytes.6 == 0,
           traceIDBytes._bytes.7 == 0,
           traceIDBytes._bytes.8 == 0,
           traceIDBytes._bytes.9 == 0,
           traceIDBytes._bytes.10 == 0,
           traceIDBytes._bytes.11 == 0,
           traceIDBytes._bytes.12 == 0,
           traceIDBytes._bytes.13 == 0,
           traceIDBytes._bytes.14 == 0,
           traceIDBytes._bytes.15 == 0
        {
            throw TraceParentDecodingError(
                .invalidTraceID(String(decoding: traceParent[3 ..< 35], as: UTF8.self))
            )
        }

        // span ID

        var spanIDBytes = SpanID.Bytes(0, 0, 0, 0, 0, 0, 0, 0)
        withUnsafeMutableBytes(of: &spanIDBytes) { ptr in
            Hex.convert(traceParent[36 ..< 52], toBytes: ptr)
        }
        if spanIDBytes._bytes.0 == 0,
           spanIDBytes._bytes.1 == 0,
           spanIDBytes._bytes.2 == 0,
           spanIDBytes._bytes.3 == 0,
           spanIDBytes._bytes.4 == 0,
           spanIDBytes._bytes.5 == 0,
           spanIDBytes._bytes.6 == 0,
           spanIDBytes._bytes.7 == 0
        {
            throw TraceParentDecodingError(
                .invalidSpanID(String(decoding: traceParent[36 ..< 52], as: UTF8.self))
            )
        }

        // flags

        var traceFlagsRawValue: UInt8 = 0
        withUnsafeMutableBytes(of: &traceFlagsRawValue) { ptr in
            Hex.convert(traceParent[53 ..< 55], toBytes: ptr)
        }
        let flags = TraceFlags(rawValue: traceFlagsRawValue)

        let state: TraceState = if let traceStateHeaderValue, !traceStateHeaderValue.isEmpty {
            try TraceState(decoding: traceStateHeaderValue)
        } else {
            TraceState()
        }

        self = TraceContext(
            traceID: TraceID(bytes: traceIDBytes),
            spanID: SpanID(bytes: spanIDBytes),
            flags: flags,
            state: state
        )
    }

    /// A string representation of the trace context parts that are propagated via the `traceparent` header.
    public var traceParentHeaderValue: String {
        let traceFlagsUnpadded = String(flags.rawValue, radix: 16, uppercase: false)
        let traceFlags = traceFlagsUnpadded.count == 1 ? "0\(traceFlagsUnpadded)" : traceFlagsUnpadded
        return "00-\(traceID)-\(spanID)-\(traceFlags)"
    }

    /// A string representation of the trace state, to be propagated via the `tracestate` header.
    public var traceStateHeaderValue: String? {
        guard !state.isEmpty else { return nil }
        return state
            .lazy
            .map { "\($0.vendor)=\($0.value)" }
            .joined(separator: ", ")
    }

    private enum DecodingState: Hashable {
        case parsingVendor
    }
}

extension TraceContext: Hashable {}

/// An error thrown while decoding a malformed trace parent header.
public struct TraceParentDecodingError: Error {
    package let reason: Reason

    init(_ reason: Reason) {
        self.reason = reason
    }

    package enum Reason: Equatable {
        case invalidTraceParentLength(Int)
        case unsupportedVersion(String)
        case invalidDelimiters
        case invalidTraceID(String)
        case invalidSpanID(String)
    }
}

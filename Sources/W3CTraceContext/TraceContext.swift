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

/// An implementation of [W3C TraceContext](https://www.w3.org/TR/2020/REC-trace-context-1-20200206/),
/// combining `TraceParent` and `TraceState`.
public struct TraceContext: Equatable {
    /// The `TraceParent` identifying this trace context.
    public let parent: TraceParent

    /// The `TraceState` containing potentially vendor-specific trace information.
    public let state: TraceState

    init(parent: TraceParent, state: TraceState) {
        self.parent = parent
        self.state = state
    }

    /// Create a `TraceContext` by parsing the given header values.
    ///
    /// - Parameters:
    ///   - parentRawValue: HTTP header value for the `traceparent` key.
    ///   - stateRawValue: HTTP header value for the `tracestate` key.
    ///
    /// When receiving multiple header fields for `tracestate`, the `state` argument should be a joined, comma-separated, `String`
    /// of all values according to [HTTP RFC 7230: Field Order](https://httpwg.org/specs/rfc7230.html#rfc.section.3.2.2).
    public init?(parent parentRawValue: String, state stateRawValue: String) {
        guard let parent = TraceParent(rawValue: parentRawValue) else { return nil }
        self.parent = parent
        self.state = TraceState(rawValue: stateRawValue) ?? TraceState([])
    }
}

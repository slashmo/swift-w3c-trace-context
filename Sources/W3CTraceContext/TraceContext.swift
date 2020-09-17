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
    public private(set) var parent: TraceParent

    /// The `TraceState` containing potentially vendor-specific trace information.
    public let state: TraceState

    /// Create a `TraceContext` from the given parent and state.
    ///
    /// - Parameters:
    ///   - parent: The `TraceParent` stored in this context.
    ///   - state: The `TraceState` stored in this context.
    public init(parent: TraceParent, state: TraceState) {
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

extension TraceContext {
    /// Replace the parent-id of the current `traceParent` with a newly generated one, using the system random number generator.
    public mutating func regenerateParentID() {
        var generator = SystemRandomNumberGenerator()
        self.regenerateParentID(using: &generator)
    }

    /// Replace the parent-id of the current `traceParent` with a newly generated one, using the given generator as a source for
    /// randomness.
    ///
    /// - Parameter generator: The random number generator used as a source for generating the new parent-id.
    public mutating func regenerateParentID<G: RandomNumberGenerator>(using generator: inout G) {
        self.parent.parentID = TraceParent.randomParentID(using: &generator)
    }

    /// Return a copy with its `traceParent.parentID` replaced with a newly generated one, using the system random number generator.
    ///
    /// - Returns: A copy of this `TraceContext` with a new trace-parent parent-id.
    public func regeneratingParentID() -> TraceContext {
        var generator = SystemRandomNumberGenerator()
        return self.regeneratingParentID(using: &generator)
    }

    /// Return a copy with its `traceParent.parentID` replaced with a newly generated one, using the system random number generator.
    ///
    /// - Parameter generator: The random number generator used as a source for generating the new parent-id.
    /// - Returns: A copy of this `TraceContext` with a new trace-parent parent-id.
    public func regeneratingParentID<G: RandomNumberGenerator>(using generator: inout G) -> TraceContext {
        var copy = self
        copy.regenerateParentID(using: &generator)
        return copy
    }
}

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

/// Represents the incoming request in a tracing system in a common format, understood by all vendors.
///
/// Example raw value: `00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01`
///
/// - SeeAlso: [W3C TraceContext: TraceParent](https://www.w3.org/TR/2020/REC-trace-context-1-20200206/#traceparent-header)
public struct TraceParent {
    /// The ID of the whole trace forest, used to uniquely identify a distributed trace through a system.
    ///
    /// - SeeAlso: [W3C TraceContext: trace-id](https://www.w3.org/TR/2020/REC-trace-context-1-20200206/#trace-id)
    public let traceID: String

    /// The ID of the incoming request as known by the caller (in some tracing systems, this is known as the span-id, where a span is the execution of
    /// a client request).
    ///
    /// - SeeAlso: [W3C TraceContext: parent-id](https://www.w3.org/TR/2020/REC-trace-context-1-20200206/#parent-id)
    public internal(set) var parentID: String

    /// An 8-bit field that controls tracing flags such as sampling, trace level, etc.
    ///
    /// - SeeAlso: [W3C TraceContext: trace-flags](https://www.w3.org/TR/2020/REC-trace-context-1-20200206/#trace-flags)
    public internal(set) var traceFlags: TraceFlags

    init(traceID: String, parentID: String, traceFlags: TraceFlags) {
        self.traceID = traceID
        self.parentID = parentID
        self.traceFlags = traceFlags
    }

    /// The HTTP header name for `TraceParent`.
    public static let headerName = "traceparent"

    /// Hard-coded version to "00" as it's the only version currently supported by this package.
    private static let version = "00"
}

extension TraceParent: Equatable {
    // custom implementation to avoid automatic equality check of rawValue which is unnecessary computational overhead
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.traceID == rhs.traceID
            && lhs.parentID == rhs.parentID
            && lhs.traceFlags == rhs.traceFlags
    }
}

extension TraceParent: RawRepresentable {
    /// Initialize a `TraceParent` from an HTTP header value. Fails if the value cannot be parsed.
    ///
    /// - Parameter rawValue: The value of the traceparent HTTP header.
    public init?(rawValue: String) {
        guard rawValue.count == 55 else { return nil }

        let components = rawValue.split(separator: "-")
        guard components.count == 4 else { return nil }

        // version
        let versionComponent = components[0]
        guard versionComponent == Self.version else { return nil }

        // trace-id
        let traceIDComponent = components[1]
        guard traceIDComponent.count == 32 else { return nil }
        guard traceIDComponent != String(repeating: "0", count: 32) else { return nil }
        self.traceID = String(traceIDComponent)

        // parent-id
        let parentIDComponent = components[2]
        guard parentIDComponent.count == 16 else { return nil }
        guard parentIDComponent != String(repeating: "0", count: 16) else { return nil }
        self.parentID = String(parentIDComponent)

        // trace-flags
        guard let traceFlags = UInt8(components[3], radix: 2).map(TraceFlags.init) else { return nil }
        self.traceFlags = traceFlags.rawValue <= 1 ? traceFlags : []
    }

    /// A `String` representation of this trace parent, suitable for injecting into HTTP headers.
    public var rawValue: String {
        "\(Self.version)-\(self.traceID)-\(self.parentID)-\(self.traceFlags)"
    }
}

extension TraceParent: CustomStringConvertible {
    public var description: String {
        self.rawValue
    }
}

extension TraceParent {
    /// Returns a random `TraceParent`, using the given generator as a source for randomness.
    /// - Parameter generator: The random number generator used as a source for generating the different values.
    /// - Note: `traceFlags` will be set to 0.
    /// - Returns: A `TraceParent` with random `traceID` & `parentID`.
    public static func random<G: RandomNumberGenerator>(using generator: inout G) -> TraceParent {
        let traceID = Self.randomTraceID(using: &generator)
        let parentID = Self.randomParentID(using: &generator)
        return .init(traceID: traceID, parentID: parentID, traceFlags: [])
    }

    /// Returns a random `TraceParent` using the system random number generator.
    /// - Note: `traceFlags` will be set to 0.
    /// - Returns: A `TraceParent` with random `traceID` & `parentID`.
    public static func random() -> TraceParent {
        var g = SystemRandomNumberGenerator()
        return .random(using: &g)
    }

    static func randomTraceID<G: RandomNumberGenerator>(using generator: inout G) -> String {
        let traceIDHigh = UInt64
            .random(in: 1 ... UInt64.max, using: &generator)
            .paddedHexString(radix: 16)
        let traceIDLow = UInt64
            .random(in: 1 ... UInt64.max, using: &generator)
            .paddedHexString(radix: 16)
        return traceIDHigh + traceIDLow
    }

    static func randomParentID<G: RandomNumberGenerator>(using generator: inout G) -> String {
        UInt64
            .random(in: 1 ... UInt64.max, using: &generator)
            .paddedHexString(radix: 16)
    }
}

extension UInt64 {
    func paddedHexString(radix: Int) -> String {
        let unpadded = String(self, radix: radix, uppercase: false)
        return String(repeating: "0", count: radix - unpadded.count) + unpadded
    }
}

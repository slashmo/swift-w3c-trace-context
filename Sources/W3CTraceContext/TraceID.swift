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

/// A unique identifier of a distributed trace through a system.
public struct TraceID {
    /// The high (left) part of this trace id.
    public let high: UInt64

    /// The low (right) part of this trace id.
    public let low: UInt64

    /// Initialize a `TraceID` with the given high and low parts.
    ///
    /// - Parameters:
    ///   - high: The high part of the trace id
    ///   - low: The low part of the trace id
    public init(high: UInt64, low: UInt64) {
        self.high = high
        self.low = low
    }

    /// Initialize a `TraceID` from the given hex string.
    ///
    /// - Parameter hexString: The hex string representation of the trace id to be initialized.
    public init?<Hex: StringProtocol>(hexString: Hex) {
        guard hexString.count == 32, hexString != Substring(repeating: "0", count: 32) else { return nil }
        let highStartIndex = hexString.startIndex
        let lowStartIndex = hexString.index(highStartIndex, offsetBy: 16)
        guard let high = UInt64(hexString[highStartIndex ..< lowStartIndex], radix: 16) else { return nil }
        guard let low = UInt64(hexString[lowStartIndex ..< hexString.endIndex], radix: 16) else { return nil }
        self.init(high: high, low: low)
    }

    /// Generate a random `TraceID`.
    ///
    /// - Returns: A random `TraceID`.
    public static func random() -> TraceID {
        var generator = SystemRandomNumberGenerator()
        return self.random(using: &generator)
    }

    /// Generate a random `TraceID` using the given `RandomNumberGenerator`.
    ///
    /// - Parameter generator: The generator used to produce the `high` and `low` part.
    /// - Returns: A random `TraceID`.
    public static func random<G: RandomNumberGenerator>(using generator: inout G) -> TraceID {
        TraceID(
            high: .random(in: 1 ... .max, using: &generator),
            low: .random(in: 1 ... .max, using: &generator)
        )
    }
}

extension TraceID: Equatable {
    public static func == (lhs: TraceID, rhs: TraceID) -> Bool {
        lhs.high == rhs.high && lhs.low == rhs.low
    }
}

extension TraceID: Comparable {
    public static func < (lhs: TraceID, rhs: TraceID) -> Bool {
        (lhs.high < rhs.high) || (lhs.high == rhs.high && lhs.low < rhs.low)
    }
}

extension TraceID: CustomStringConvertible {
    public var description: String {
        let highHex = self.high.paddedHexString(radix: 16)
        let lowHex = self.low.paddedHexString(radix: 16)
        return "\(highHex)\(lowHex)"
    }
}

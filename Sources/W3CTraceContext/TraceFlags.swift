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

/// Represents an 8-bit field that controls tracing flags such as sampling.
public struct TraceFlags: OptionSet {
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    /// [W3C TraceContext: Sampled flag](https://www.w3.org/TR/2020/REC-trace-context-1-20200206/#sampled-flag)
    public static let sampled = TraceFlags(rawValue: 1 << 0)
}

extension TraceFlags: CustomStringConvertible {
    public var description: String {
        let radix = 2
        let unpadded = String(self.rawValue, radix: radix, uppercase: false)
        return String(repeating: "0", count: radix - unpadded.count) + unpadded
    }
}

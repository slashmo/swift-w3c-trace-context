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

/// Uniquely identifies a distributed tracing span using an 8-byte array.
///
/// [W3C TraceContext: parent-id](https://www.w3.org/TR/trace-context-1/#parent-id)
public struct SpanID: Sendable {
    private let _bytes: Bytes

    /// An 8-byte array representation of the span ID.
    public var bytes: [UInt8] {
        withUnsafeBytes(of: _bytes, Array.init)
    }

    /// Create a span ID from 8 bytes.
    ///
    /// - Parameter bytes: The 8 bytes making up the span ID.
    public init(bytes: Bytes) {
        _bytes = bytes
    }

    /// Create a random span ID using the given random number generator.
    ///
    /// - Parameter randomNumberGenerator: The random number generator used to create random bytes for the span ID.
    /// - Returns: A random span ID.
    public static func random(using randomNumberGenerator: inout some RandomNumberGenerator) -> SpanID {
        var bytes: SpanID.Bytes = (0, 0, 0, 0, 0, 0, 0, 0)
        withUnsafeMutableBytes(of: &bytes) { ptr in
            ptr.storeBytes(of: randomNumberGenerator.next().bigEndian, as: UInt64.self)
        }
        return SpanID(bytes: bytes)
    }

    /// Create a random span ID.
    ///
    /// - Returns: A random span ID.
    public static func random() -> SpanID {
        var generator = SystemRandomNumberGenerator()
        return random(using: &generator)
    }

    /// An 8-byte array.
    public typealias Bytes = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
}

extension SpanID: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs._bytes.0 == rhs._bytes.0
            && lhs._bytes.1 == rhs._bytes.1
            && lhs._bytes.2 == rhs._bytes.2
            && lhs._bytes.3 == rhs._bytes.3
            && lhs._bytes.4 == rhs._bytes.4
            && lhs._bytes.5 == rhs._bytes.5
            && lhs._bytes.6 == rhs._bytes.6
            && lhs._bytes.7 == rhs._bytes.7
    }
}

extension SpanID: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_bytes.0)
        hasher.combine(_bytes.1)
        hasher.combine(_bytes.2)
        hasher.combine(_bytes.3)
        hasher.combine(_bytes.4)
        hasher.combine(_bytes.5)
        hasher.combine(_bytes.6)
        hasher.combine(_bytes.7)
    }
}

extension SpanID: Identifiable {
    public var id: [UInt8] { bytes }
}

extension SpanID: CustomStringConvertible {
    /// A 16 character hex string representation of the span ID.
    public var description: String {
        String(decoding: hexBytes, as: UTF8.self)
    }

    /// A 16 character UTF-8 hex byte array representation of the span ID.
    public var hexBytes: [UInt8] {
        var asciiBytes: (UInt64, UInt64) = (0, 0)
        return withUnsafeMutableBytes(of: &asciiBytes) { ptr in
            ptr[0] = Hex.lookup[Int(_bytes.0 >> 4)]
            ptr[1] = Hex.lookup[Int(_bytes.0 & 0x0F)]
            ptr[2] = Hex.lookup[Int(_bytes.1 >> 4)]
            ptr[3] = Hex.lookup[Int(_bytes.1 & 0x0F)]
            ptr[4] = Hex.lookup[Int(_bytes.2 >> 4)]
            ptr[5] = Hex.lookup[Int(_bytes.2 & 0x0F)]
            ptr[6] = Hex.lookup[Int(_bytes.3 >> 4)]
            ptr[7] = Hex.lookup[Int(_bytes.3 & 0x0F)]
            ptr[8] = Hex.lookup[Int(_bytes.4 >> 4)]
            ptr[9] = Hex.lookup[Int(_bytes.4 & 0x0F)]
            ptr[10] = Hex.lookup[Int(_bytes.5 >> 4)]
            ptr[11] = Hex.lookup[Int(_bytes.5 & 0x0F)]
            ptr[12] = Hex.lookup[Int(_bytes.6 >> 4)]
            ptr[13] = Hex.lookup[Int(_bytes.6 & 0x0F)]
            ptr[14] = Hex.lookup[Int(_bytes.7 >> 4)]
            ptr[15] = Hex.lookup[Int(_bytes.7 & 0x0F)]
            return Array(ptr)
        }
    }
}

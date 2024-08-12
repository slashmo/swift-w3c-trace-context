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
    public let bytes: Bytes

    /// Create a span ID from 8 bytes.
    ///
    /// - Parameter bytes: The 8 bytes making up the span ID.
    public init(bytes: Bytes) {
        self.bytes = bytes
    }

    public init(bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)) {
        self.bytes = Bytes(bytes)
    }

    @inlinable
    public func withUnsafeBytes<Result>(_ body: (UnsafeRawBufferPointer) throws -> Result) rethrows -> Result {
        try Swift.withUnsafeBytes(of: self.bytes._bytes, body)
    }

    /// Create a random span ID using the given random number generator.
    ///
    /// - Parameter randomNumberGenerator: The random number generator used to create random bytes for the span ID.
    /// - Returns: A random span ID.
    public static func random(using randomNumberGenerator: inout some RandomNumberGenerator) -> SpanID {
        var bytes: SpanID.Bytes = .init(0, 0, 0, 0, 0, 0, 0, 0)
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
    public struct Bytes: Equatable, Hashable, Sendable {
        @usableFromInline
        let _bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)

        public init(_ bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)) {
            _bytes = bytes
        }

        public init(_ one: UInt8, _ two: UInt8, _ three: UInt8, _ four: UInt8, _ five: UInt8, _ six: UInt8, _ seven: UInt8, _ eight: UInt8) {
            _bytes = (one, two, three, four, five, six, seven, eight)
        }

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
}

extension SpanID: Equatable {
    
}

extension SpanID: Hashable {
    
}

extension SpanID: Identifiable {
    public var id: Bytes { bytes }
}

extension SpanID: CustomStringConvertible {
    /// A 16 character hex string representation of the span ID.
    public var description: String {
        String(decoding: self.bytes.hexBytes, as: UTF8.self)
    }

}

extension SpanID.Bytes {

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

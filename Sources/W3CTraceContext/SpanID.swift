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
    /// The 8 bytes making up the span ID.
    public let bytes: Bytes

    /// Create a span ID from 8 bytes.
    ///
    /// - Parameter bytes: The 8 bytes making up the span ID.
    public init(bytes: Bytes) {
        self.bytes = bytes
    }

    /// An invalid span ID with all bytes set to 0.
    public static var invalid: SpanID { SpanID(bytes: .null) }

    /// Create a random span ID using the given random number generator.
    ///
    /// - Parameter randomNumberGenerator: The random number generator used to create random bytes for the span ID.
    /// - Returns: A random span ID.
    public static func random(using randomNumberGenerator: inout some RandomNumberGenerator) -> SpanID {
        var bytes: SpanID.Bytes = .null
        bytes.withUnsafeMutableBytes { ptr in
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
    public struct Bytes: Collection, Equatable, Hashable, Sendable {
        public static var null: Self { SpanID.Bytes((0, 0, 0, 0, 0, 0, 0, 0)) }

        @usableFromInline
        var _bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)

        public init(_ bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)) {
            _bytes = bytes
        }

        public subscript(position: Int) -> UInt8 {
            switch position {
            case 0: _bytes.0
            case 1: _bytes.1
            case 2: _bytes.2
            case 3: _bytes.3
            case 4: _bytes.4
            case 5: _bytes.5
            case 6: _bytes.6
            case 7: _bytes.7
            default: fatalError("Index out of range")
            }
        }

        public func index(after i: Int) -> Int {
            precondition(i < endIndex, "Can't advance beyond endIndex")
            return i + 1
        }

        public var startIndex: Int { 0 }
        public var endIndex: Int { 8 }

        @inlinable
        public func withContiguousStorageIfAvailable<Result>(_ body: (UnsafeBufferPointer<UInt8>) throws -> Result) rethrows -> Result? {
            try Swift.withUnsafeBytes(of: _bytes) { bytes in
                try bytes.withMemoryRebound(to: UInt8.self, body)
            }
        }

        /// Calls the given closure with a pointer to the span ID's underlying bytes.
        ///
        /// - Parameter body: A closure receiving an `UnsafeRawBufferPointer` to the span ID's underlying bytes.
        @inlinable
        public func withUnsafeBytes<Result>(_ body: (UnsafeRawBufferPointer) throws -> Result) rethrows -> Result {
            try Swift.withUnsafeBytes(of: _bytes, body)
        }

        /// Calls the given closure with a mutable pointer to the span ID's underlying bytes.
        ///
        /// - Parameter body: A closure receiving an `UnsafeMutableRawBufferPointer` to the span ID's underlying bytes.
        @inlinable
        public mutating func withUnsafeMutableBytes<Result>(_ body: (UnsafeMutableRawBufferPointer) throws -> Result) rethrows -> Result {
            try Swift.withUnsafeMutableBytes(of: &_bytes) { bytes in
                try body(bytes)
            }
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

extension SpanID.Bytes: CustomStringConvertible {
    /// A 16 character hex string representation of the bytes.
    public var description: String {
        String(decoding: hexBytes, as: UTF8.self)
    }

    /// A 16 character UTF-8 hex byte array representation of the bytes.
    public var hexBytes: [UInt8] {
        var asciiBytes = [UInt8](repeating: 0, count: 16)
        for i in startIndex ..< endIndex {
            let byte = self[i]
            asciiBytes[2 * i] = Hex.lookup[Int(byte >> 4)]
            asciiBytes[2 * i + 1] = Hex.lookup[Int(byte & 0x0F)]
        }
        return asciiBytes
    }
}

extension SpanID: Equatable {}

extension SpanID: Hashable {}

extension SpanID: Identifiable {
    public var id: Self { self }
}

extension SpanID: CustomStringConvertible {
    /// A 16 character hex string representation of the span ID.
    public var description: String {
        "\(bytes)"
    }

    /// A 16 character UTF-8 hex byte array representation of the span ID.
    public var hexBytes: [UInt8] {
        bytes.hexBytes
    }
}

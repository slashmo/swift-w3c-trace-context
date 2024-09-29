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

/// Uniquely identifies a distributed trace using a 16-byte array.
///
/// [W3C TraceContext: trace-id](https://www.w3.org/TR/trace-context-1/#trace-id)
public struct TraceID: Sendable {
    /// The 16 bytes making up the trace ID.
    public let bytes: Bytes

    /// Create a trace ID from 16 bytes.
    ///
    /// - Parameter bytes: The 16 bytes making up the trace ID.
    public init(bytes: Bytes) {
        self.bytes = bytes
    }

    /// Create a random trace ID using the given random number generator.
    ///
    /// - Parameter randomNumberGenerator: The random number generator used to create random bytes for the trace ID.
    /// - Returns: A random trace ID.
    public static func random(using randomNumberGenerator: inout some RandomNumberGenerator) -> TraceID {
        var bytes: TraceID.Bytes = .null
        bytes.withUnsafeMutableBytes { ptr in
            let rand1 = randomNumberGenerator.next()
            let rand2 = randomNumberGenerator.next()
            ptr.storeBytes(of: rand1.bigEndian, toByteOffset: 0, as: UInt64.self)
            ptr.storeBytes(of: rand2.bigEndian, toByteOffset: 8, as: UInt64.self)
        }
        return TraceID(bytes: bytes)
    }

    /// Create a random trace ID.
    ///
    /// - Returns: A random trace ID.
    public static func random() -> TraceID {
        var generator = SystemRandomNumberGenerator()
        return random(using: &generator)
    }
}

extension TraceID: Equatable {}

extension TraceID: Hashable {}

extension TraceID: Identifiable {
    public var id: Self { self }
}

extension TraceID: CustomStringConvertible {
    /// A 32-character hex string representation of the trace ID.
    public var description: String {
        "\(bytes)"
    }
}

// MARK: - Bytes

extension TraceID {
    /// A 16-byte array.
    public struct Bytes: Collection, Equatable, Hashable, Sendable {
        public static var null: Self { TraceID.Bytes((0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)) }

        @usableFromInline
        var _bytes: (
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
        )

        public init(_ bytes: (
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
        )) {
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
            case 8: _bytes.8
            case 9: _bytes.9
            case 10: _bytes.10
            case 11: _bytes.11
            case 12: _bytes.12
            case 13: _bytes.13
            case 14: _bytes.14
            case 15: _bytes.15
            default: fatalError("Index out of range")
            }
        }

        public func index(after i: Int) -> Int {
            precondition(i < endIndex, "Can't advance beyond endIndex")
            return i + 1
        }

        public var startIndex: Int { 0 }
        public var endIndex: Int { 16 }

        @inlinable
        public func withContiguousStorageIfAvailable<Result>(
            _ body: (UnsafeBufferPointer<UInt8>) throws -> Result
        ) rethrows -> Result? {
            try Swift.withUnsafeBytes(of: _bytes) { bytes in
                try bytes.withMemoryRebound(to: UInt8.self, body)
            }
        }

        /// Calls the given closure with a pointer to the trace ID's underlying bytes.
        /// - Parameter body: A closure receiving an `UnsafeRawBufferPointer` to the trace ID's underlying bytes.
        @inlinable
        public func withUnsafeBytes<Result>(
            _ body: (UnsafeRawBufferPointer) throws -> Result
        ) rethrows -> Result {
            try Swift.withUnsafeBytes(of: _bytes, body)
        }

        /// Calls the given closure with a mutable pointer to the trace ID's underlying bytes.
        /// - Parameter body: A closure receiving an `UnsafeMutableRawBufferPointer` to the trace ID's underlying bytes.
        @inlinable
        public mutating func withUnsafeMutableBytes<Result>(
            _ body: (UnsafeMutableRawBufferPointer) throws -> Result
        ) rethrows -> Result {
            try Swift.withUnsafeMutableBytes(of: &_bytes) { bytes in
                try body(bytes)
            }
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs._bytes.0 == rhs._bytes.0 &&
                lhs._bytes.1 == rhs._bytes.1 &&
                lhs._bytes.2 == rhs._bytes.2 &&
                lhs._bytes.3 == rhs._bytes.3 &&
                lhs._bytes.4 == rhs._bytes.4 &&
                lhs._bytes.5 == rhs._bytes.5 &&
                lhs._bytes.6 == rhs._bytes.6 &&
                lhs._bytes.7 == rhs._bytes.7 &&
                lhs._bytes.8 == rhs._bytes.8 &&
                lhs._bytes.9 == rhs._bytes.9 &&
                lhs._bytes.10 == rhs._bytes.10 &&
                lhs._bytes.11 == rhs._bytes.11 &&
                lhs._bytes.12 == rhs._bytes.12 &&
                lhs._bytes.13 == rhs._bytes.13 &&
                lhs._bytes.14 == rhs._bytes.14 &&
                lhs._bytes.15 == rhs._bytes.15
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
            hasher.combine(_bytes.8)
            hasher.combine(_bytes.9)
            hasher.combine(_bytes.10)
            hasher.combine(_bytes.11)
            hasher.combine(_bytes.12)
            hasher.combine(_bytes.13)
            hasher.combine(_bytes.14)
            hasher.combine(_bytes.15)
        }
    }
}

extension TraceID.Bytes: CustomStringConvertible {
    /// A 32-character hex string representation of the bytes.
    public var description: String {
        String(decoding: hexBytes, as: UTF8.self)
    }

    /// A 32-character UTF-8 hex byte array representation of the bytes.
    public var hexBytes: [UInt8] {
        var asciiBytes = [UInt8](repeating: 0, count: 32)
        for i in startIndex ..< endIndex {
            let byte = self[i]
            asciiBytes[2 * i] = Hex.lookup[Int(byte >> 4)]
            asciiBytes[2 * i + 1] = Hex.lookup[Int(byte & 0x0F)]
        }
        return asciiBytes
    }
}

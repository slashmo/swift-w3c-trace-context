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
    /// The 16-bytes of the trace ID.
    public let bytes: Bytes

    /// A 16-byte array representation of the trace ID.
    public var bytesArray: [UInt8] {
        withUnsafeBytes(of: bytes, Array.init)
    }

    /// Create a trace ID from 16 bytes.
    ///
    /// - Parameter bytes: The 16 bytes making up the trace ID.
    public init(bytes: Bytes) {
        self.bytes = bytes
    }

    /// Create a trace ID from 16 bytes.
    ///
    /// - Parameter bytes: The 16 bytes making up the trace ID.
    public init(bytes: Bytes.Storage) {
        self.bytes = .init(bytes)
    }

    /// Create a random trace ID using the given random number generator.
    ///
    /// - Parameter randomNumberGenerator: The random number generator used to create random bytes for the trace ID.
    /// - Returns: A random trace ID.
    public static func random(using randomNumberGenerator: inout some RandomNumberGenerator) -> TraceID {
        var bytes: TraceID.Bytes.Storage = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        withUnsafeMutableBytes(of: &bytes) { ptr in
            ptr.storeBytes(of: randomNumberGenerator.next().bigEndian, as: UInt64.self)
            ptr.storeBytes(of: randomNumberGenerator.next().bigEndian, toByteOffset: 8, as: UInt64.self)
        }
        return TraceID(bytes: .init(bytes))
    }

    /// Create a random trace ID.
    ///
    /// - Returns: A random trace ID.
    public static func random() -> TraceID {
        var generator = SystemRandomNumberGenerator()
        return random(using: &generator)
    }

    /// A 16-byte array.
    public struct Bytes: Sendable {
    
        public typealias Storage = (
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
        )

        /* private */ public let _storage: Storage

        public init(_ bytes: Storage) {
            self._storage = bytes
        }

        public var array: [UInt8] {
            Swift.withUnsafeBytes(of: _storage, Array.init)
        }

        @inlinable
        public func withUnsafeBytes<Result>(
            _ body: (UnsafeRawBufferPointer) throws -> Result
        ) rethrows -> Result {
            try Swift.withUnsafeBytes(of: _storage, body)
        }

    }
}

extension TraceID : Equatable {}
extension TraceID : Hashable {}

extension TraceID.Bytes: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs._storage.0 == rhs._storage.0
            && lhs._storage.1 == rhs._storage.1
            && lhs._storage.2 == rhs._storage.2
            && lhs._storage.3 == rhs._storage.3
            && lhs._storage.4 == rhs._storage.4
            && lhs._storage.5 == rhs._storage.5
            && lhs._storage.6 == rhs._storage.6
            && lhs._storage.7 == rhs._storage.7
            && lhs._storage.8 == rhs._storage.8
            && lhs._storage.9 == rhs._storage.9
            && lhs._storage.10 == rhs._storage.10
            && lhs._storage.11 == rhs._storage.11
            && lhs._storage.12 == rhs._storage.12
            && lhs._storage.13 == rhs._storage.13
            && lhs._storage.14 == rhs._storage.14
            && lhs._storage.15 == rhs._storage.15
    }
}

extension TraceID.Bytes: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_storage.0)
        hasher.combine(_storage.1)
        hasher.combine(_storage.2)
        hasher.combine(_storage.3)
        hasher.combine(_storage.4)
        hasher.combine(_storage.5)
        hasher.combine(_storage.6)
        hasher.combine(_storage.7)
        hasher.combine(_storage.8)
        hasher.combine(_storage.9)
        hasher.combine(_storage.10)
        hasher.combine(_storage.11)
        hasher.combine(_storage.12)
        hasher.combine(_storage.13)
        hasher.combine(_storage.14)
        hasher.combine(_storage.15)
    }
}

extension TraceID: Identifiable {
    public var id: Bytes { bytes }
}

extension TraceID.Bytes: CustomStringConvertible {
    /// A 32 character hex string representation of the bytes.
    public var description: String {
        String(decoding: hexBytes, as: UTF8.self)
    }

    /// A 32 character UTF-8 hex byte array representation of the bytes ID.
    public var hexBytes: [UInt8] {
        var asciiBytes: (UInt64, UInt64, UInt64, UInt64) = (0, 0, 0, 0)
        return withUnsafeMutableBytes(of: &asciiBytes) { ptr in
            ptr[0] = Hex.lookup[Int(_storage.0 >> 4)]
            ptr[1] = Hex.lookup[Int(_storage.0 & 0x0F)]
            ptr[2] = Hex.lookup[Int(_storage.1 >> 4)]
            ptr[3] = Hex.lookup[Int(_storage.1 & 0x0F)]
            ptr[4] = Hex.lookup[Int(_storage.2 >> 4)]
            ptr[5] = Hex.lookup[Int(_storage.2 & 0x0F)]
            ptr[6] = Hex.lookup[Int(_storage.3 >> 4)]
            ptr[7] = Hex.lookup[Int(_storage.3 & 0x0F)]
            ptr[8] = Hex.lookup[Int(_storage.4 >> 4)]
            ptr[9] = Hex.lookup[Int(_storage.4 & 0x0F)]
            ptr[10] = Hex.lookup[Int(_storage.5 >> 4)]
            ptr[11] = Hex.lookup[Int(_storage.5 & 0x0F)]
            ptr[12] = Hex.lookup[Int(_storage.6 >> 4)]
            ptr[13] = Hex.lookup[Int(_storage.6 & 0x0F)]
            ptr[14] = Hex.lookup[Int(_storage.7 >> 4)]
            ptr[15] = Hex.lookup[Int(_storage.7 & 0x0F)]
            ptr[16] = Hex.lookup[Int(_storage.8 >> 4)]
            ptr[17] = Hex.lookup[Int(_storage.8 & 0x0F)]
            ptr[18] = Hex.lookup[Int(_storage.9 >> 4)]
            ptr[19] = Hex.lookup[Int(_storage.9 & 0x0F)]
            ptr[20] = Hex.lookup[Int(_storage.10 >> 4)]
            ptr[21] = Hex.lookup[Int(_storage.10 & 0x0F)]
            ptr[22] = Hex.lookup[Int(_storage.11 >> 4)]
            ptr[23] = Hex.lookup[Int(_storage.11 & 0x0F)]
            ptr[24] = Hex.lookup[Int(_storage.12 >> 4)]
            ptr[25] = Hex.lookup[Int(_storage.12 & 0x0F)]
            ptr[26] = Hex.lookup[Int(_storage.13 >> 4)]
            ptr[27] = Hex.lookup[Int(_storage.13 & 0x0F)]
            ptr[28] = Hex.lookup[Int(_storage.14 >> 4)]
            ptr[29] = Hex.lookup[Int(_storage.14 & 0x0F)]
            ptr[30] = Hex.lookup[Int(_storage.15 >> 4)]
            ptr[31] = Hex.lookup[Int(_storage.15 & 0x0F)]
            return Array(ptr)
        }
    }
}

extension TraceID: CustomStringConvertible {
    /// A 32 character hex string representation of the span ID.
    public var description: String {
        String(decoding: self.bytes.hexBytes, as: UTF8.self)
    }

    /// A 32 character UTF-8 hex byte array representation of the span ID.
    public var hexBytes: [UInt8] {
        self.bytes.hexBytes
    }
}

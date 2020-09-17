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

/// Provides additional vendor-specific trace identification information across different distributed tracing systems and is a companion header for the
/// traceparent field.
///
/// Example raw value: `rojo=00f067aa0ba902b7,congo=t61rcWkgMzE`
///
/// - SeeAlso: [W3C TraceContext: TraceState](https://www.w3.org/TR/2020/REC-trace-context-1-20200206/#tracestate-header)
public struct TraceState {
    typealias Storage = [(vendor: String, value: String)]

    private var _storage: Storage

    init(_ storage: Storage) {
        self._storage = storage
    }

    /// The HTTP header name for `TraceState`.
    public static let headerName = "tracestate"
}

extension TraceState {
    /// Creates an empty `TraceState`.
    public static var none: TraceState {
        .init([])
    }
}

extension TraceState: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs._storage.count == rhs._storage.count else { return false }
        for (index, (lhsVendor, lhsValue)) in lhs._storage.enumerated() {
            let (rhsVendor, rhsValue) = rhs._storage[index]
            guard lhsVendor == rhsVendor, lhsValue == rhsValue else { return false }
        }
        return true
    }
}

extension TraceState: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension TraceState: RawRepresentable {
    /// Initialize a `TraceState` from an HTTP header value. Fails if the value cannot be parsed.
    ///
    /// - Parameter rawValue: The value of the tracestate HTTP header.
    /// - Note: When receiving multiple header fields for `tracestate`, `rawValue` should be a joined, comma-separated `String` of all values
    /// according to [HTTP RFC 7230: Field Order](https://httpwg.org/specs/rfc7230.html#rfc.section.3.2.2).
    public init?(rawValue: String) {
        let keyValuePairs = rawValue.split(separator: ",")
        let horizontalSpaces = Set<Character>([" ", "\t"])
        var storage = Storage()

        for var rest in keyValuePairs {
            while !rest.isEmpty {
                if horizontalSpaces.contains(rest[rest.startIndex]) {
                    rest.removeFirst()
                } else if horizontalSpaces.contains(rest[rest.index(before: rest.endIndex)]) {
                    rest.removeLast()
                } else {
                    break
                }
            }

            guard !rest.isEmpty else {
                self._storage = Storage()
                return
            }

            var vendor = ""

            while vendor.count < 256, !rest.hasPrefix("="), !rest.isEmpty {
                let next = rest.removeFirst()
                switch next {
                case "a" ... "z", "0" ... "9", "_", "-", "*", "/":
                    vendor.append(next)
                case "@":
                    guard !rest.hasPrefix("=") else { return nil }
                    vendor.append(next)
                default:
                    return nil
                }
            }

            guard !vendor.isEmpty, rest.hasPrefix("=") else { return nil }
            rest.removeFirst()

            var value = ""

            while value.count < 256, !rest.isEmpty {
                value += String(rest.removeFirst())
            }

            storage.append((vendor: vendor, value: value))
        }

        self._storage = storage
    }

    /// A `String` representation of this trace state, suitable for injecting into HTTP headers.
    public var rawValue: String {
        self._storage.map { "\($0)=\($1)" }.joined(separator: ",")
    }
}

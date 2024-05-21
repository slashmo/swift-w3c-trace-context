import OrderedCollections

/// Vendor-specific string values to be propagated alongside a distributed tracing span.
///
/// [W3C TraceContext: trace-state](https://www.w3.org/TR/trace-context-1/#tracestate-header)
public struct TraceState: Sendable {
    private var _entries: OrderedDictionary<Vendor, String>

    /// Access the value of the given vendor for reading and writing.
    public subscript(_ vendor: Vendor) -> String? {
        get {
            _entries[vendor]
        }
        set {
            if _entries.keys.contains(vendor), let value = newValue {
                // update the existing entry and move it to the front of the list
                _entries.removeValue(forKey: vendor)
                _entries.updateValue(value, forKey: vendor, insertingAt: 0)
            } else if let value = newValue {
                // insert the latest entry to the front list
                _entries.updateValue(value, forKey: vendor, insertingAt: 0)
            } else {
                _entries.removeValue(forKey: vendor)
            }
        }
    }

    /// Whether the trace state is empty.
    public var isEmpty: Bool { _entries.isEmpty }

    /// The number of entries stored in the trace state.
    public var count: Int { _entries.count }

    /// Create an empty ``TraceState``.
    public init() {
        self._entries = [:]
    }

    /// Create a ``TraceState`` from a sequence of vendor/value pairs.
    ///
    /// Vendors are expected to be unique. When multiple values for a given vendor exist, the last most
    /// value will be used.
    ///
    /// - Parameter entries: A sequence of vendor/value pairs to store in a ``TraceState``.
    public init(_ entries: some Sequence<(Vendor, String)>) {
        _entries = .init(entries, uniquingKeysWith: { $1 })
    }

    /// A vendor, acting as the unique key in ``TraceState``.
    ///
    /// Vendors can either be ``Vendor/simple(_:)``, e.g. `"my-vendor"`
    /// or denote a ``Vendor/tenant(_:in:)`` in a multi-tenant system, e.g. `"tenant@my-system"`.
    public struct Vendor: RawRepresentable, Sendable, Hashable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        /// Create a simple vendor from the given String.
        ///
        /// - Parameter value: The name of the vendor.
        public static func simple(_ value: String) -> Vendor {
            Vendor(rawValue: value)
        }

        /// Create a multi-tenant system vendor.
        ///
        /// - Parameters:
        ///   - tenant: A specific tenant within a multi-tenant system.
        ///   - system: The name of the multi-tenant system.
        public static func tenant(_ tenant: String, in system: String) -> Vendor {
            Vendor(rawValue: "\(tenant)@\(system)")
        }
    }
}

extension TraceState: Sequence {
    public struct Element: Hashable {
        public let vendor: Vendor
        public let value: String

        package init(vendor: Vendor, value: String) {
            self.vendor = vendor
            self.value = value
        }
    }

    public func makeIterator() -> Iterator {
        Iterator(_entries)
    }

    public struct Iterator: IteratorProtocol {
        public typealias Element = TraceState.Element
        private var _iterator: OrderedDictionary<Vendor, String>.Iterator

        fileprivate init(_ elements: OrderedDictionary<Vendor, String>) {
            self._iterator = elements.makeIterator()
        }

        public mutating func next() -> TraceState.Element? {
            guard let entry = _iterator.next() else { return nil }
            return Element(vendor: entry.key, value: entry.value)
        }
    }
}

extension TraceState: Hashable {}

extension TraceState.Vendor: CustomStringConvertible {
    public var description: String { rawValue }
}

// MARK: - Decoding

extension TraceState {
    package init(decoding headerValue: String) throws {
        var value = headerValue[...]
        var index = headerValue.startIndex
        var state = HeaderDecodingState.tenantOrVendor([])
        var entries = [(Vendor, String)]()

        while let next = value.popFirst() {
            defer { index = headerValue.index(after: index) }
            switch state {
            case .tenantOrVendor(let tenantOrVendor):
                switch next {
                case "a" ... "z", "0" ... "9", "_", "-", "*", "/":
                    // keep adding to the tenant or vendor part
                    state = .tenantOrVendor(tenantOrVendor + next.utf8)
                case "@":
                    // transition from tenant to system part
                    guard tenantOrVendor.count <= Constant.maximumTenantLength else {
                        let tenantRange = headerValue.index(index, offsetBy: -tenantOrVendor.count) ... headerValue.index(before: index)
                        throw TraceStateDecodingError(
                            reason: .multiTenantVendorTenantTooLong(tenantRange),
                            headerValue: headerValue
                        )
                    }
                    let tenant = String(decoding: tenantOrVendor, as: UTF8.self)
                    state = .system(tenant: tenant, system: [])
                case "=":
                    // transition from simple tenant to value part
                    let vendor = String(decoding: tenantOrVendor, as: UTF8.self)
                    guard tenantOrVendor.count <= Constant.maximumSimpleVendorLength else {
                        let vendorRange = headerValue.index(index, offsetBy: -tenantOrVendor.count) ... headerValue.index(before: index)
                        throw TraceStateDecodingError(
                            reason: .simpleVendorTooLong(vendorRange),
                            headerValue: headerValue
                        )
                    }
                    state = .value(.simple(vendor), [])
                default:
                    throw TraceStateDecodingError(reason: .malformedCharacterInVendor(index), headerValue: headerValue)
                }
            case let .system(tenant, system):
                switch next {
                case "a" ... "z", "0" ... "9", "_", "-", "*", "/":
                    state = .system(tenant: tenant, system: system + next.utf8)
                case "=":
                    // transition from tenant to value part
                    let system = String(decoding: system, as: UTF8.self)
                    guard system.count <= Constant.maximumSystemLength else {
                        let systemRange = headerValue.index(index, offsetBy: -system.count) ... headerValue.index(before: index)
                        throw TraceStateDecodingError(
                            reason: .multiTenantVendorSystemTooLong(systemRange),
                            headerValue: headerValue
                        )
                    }
                    state = .value(.tenant(tenant, in: system), [])
                default:
                    throw TraceStateDecodingError(reason: .malformedCharacterInVendor(index), headerValue: headerValue)
                }
            case let .value(vendor, valuePart):
                switch next {
                case ",":
                    // discard any leading whitespace before the next vendor part
                    let whitespace = value.prefix(while: { $0 == " " })
                    value.removeFirst(whitespace.count)

                    entries.append((vendor, String(decoding: valuePart, as: UTF8.self)))
                    state = .tenantOrVendor([])
                case " " ... "~":
                    guard valuePart.count < Constant.maximumValueLength else {
                        throw TraceStateDecodingError(
                            reason: .valueTooLong(vendor: vendor),
                            headerValue: headerValue
                        )
                    }
                    state = .value(vendor, valuePart + next.utf8)
                default:
                    throw TraceStateDecodingError(reason: .malformedCharacterInValue(index), headerValue: headerValue)
                }
            }
        }

        if case .value(let vendor, let value) = state {
            entries.append((vendor, String(decoding: value, as: UTF8.self)))
        }

        self.init(entries)
    }

    private enum HeaderDecodingState: Hashable {
        case tenantOrVendor([UInt8])
        case system(tenant: String, system: [UInt8])
        case value(Vendor, [UInt8])
    }

    fileprivate enum Constant {
        static let maximumSimpleVendorLength = 265
        static let maximumTenantLength = 241
        static let maximumSystemLength = 14
        static let maximumValueLength = 265
    }
}

/// Errors thrown while decoding a malformed trace state header.
public struct TraceStateDecodingError: Error, CustomDebugStringConvertible {
    package let reason: Reason
    package let headerValue: String

    public var debugDescription: String {
        switch reason {
        case .malformedCharacterInVendor(let characterIndex):
            let index = characterIndex.utf16Offset(in: headerValue)
            let indicator = String(repeating: " ", count: index) + "^"
            return """
            Trace state vendor contains malformed character.
            \(headerValue)
            \(indicator)
            """
        case .malformedCharacterInValue(let characterIndex):
            let index = characterIndex.utf16Offset(in: headerValue)
            let indicator = String(repeating: " ", count: index) + "^"
            return """
            Trace state value contains malformed character.
            \(headerValue)
            \(indicator)
            """
        case .simpleVendorTooLong(let vendorRange):
            let endIndex = vendorRange.upperBound.utf16Offset(in: headerValue)
            let indicator = String(repeating: " ", count: endIndex) + "^"
            return """
            Vendor in trace state exceeds maximum allowed length of \(TraceState.Constant.maximumSimpleVendorLength).
            \(headerValue)
            \(indicator)
            """
        case .multiTenantVendorTenantTooLong(let tenantRange):
            let endIndex = tenantRange.upperBound.utf16Offset(in: headerValue)
            let indicator = String(repeating: " ", count: endIndex) + "^"
            return """
            Tenant in trace state exceeds maximum allowed length of \(TraceState.Constant.maximumTenantLength).
            \(headerValue)
            \(indicator)
            """
        case .multiTenantVendorSystemTooLong(let systemRange):
            let endIndex = systemRange.upperBound.utf16Offset(in: headerValue)
            let indicator = String(repeating: " ", count: endIndex) + "^"
            return """
            Multi-tenant system ID in trace state exceeds maximum allowed length of \
            \(TraceState.Constant.maximumTenantLength).
            \(headerValue)
            \(indicator)
            """
        case .valueTooLong(let vendor):
            return """
            Value for vendor "\(vendor)" exceeds maximum allowed length of \
            \(TraceState.Constant.maximumValueLength).
            """
        }
    }

    package enum Reason: Equatable {
        case malformedCharacterInVendor(_ malformedCharacterIndex: String.Index)
        case malformedCharacterInValue(_ malformedCharacterIndex: String.Index)
        case simpleVendorTooLong(_ vendorRange: ClosedRange<String.Index>)
        case multiTenantVendorTenantTooLong(_ tenantRange: ClosedRange<String.Index>)
        case multiTenantVendorSystemTooLong(_ systemRange: ClosedRange<String.Index>)
        case valueTooLong(vendor: TraceState.Vendor)
    }
}

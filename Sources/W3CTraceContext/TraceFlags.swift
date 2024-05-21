/// An 8-bit field representing tracing flags such as sampling.
///
/// [W3C TraceContext: trace-flags](https://www.w3.org/TR/trace-context-1/#trace-flags)
public struct TraceFlags: OptionSet, Sendable {
    /// An 8-bit representation of the trace flags.
    public let rawValue: UInt8

    /// Create trace flags from the given 8-bit representation.
    ///
    /// - Parameter rawValue: The 8-bit value representing zero or more trace flags.
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    /// Create empty trace flags.
    public init() {
        self.init(rawValue: 0)
    }

    /// Whether the span was sampled.
    ///
    /// [W3C TraceContext: Sampled flag](https://www.w3.org/TR/trace-context-1/#sampled-flag)
    public static let sampled = TraceFlags(rawValue: 1)
}

extension TraceFlags: Hashable {}

extension TraceFlags: CustomStringConvertible {
    /// A 2-character UTF-8 hex string representation of the trace flags.
    public var description: String {
        let traceFlagsUnpadded = String(rawValue, radix: 16, uppercase: false)
        return traceFlagsUnpadded.count == 1 ? "0\(traceFlagsUnpadded)" : traceFlagsUnpadded
    }
}

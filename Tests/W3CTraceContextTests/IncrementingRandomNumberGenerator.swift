import Dispatch

/// A random number generator starting at 0 and incrementing by 1 for each generated number.
final class IncrementingRandomNumberGenerator: RandomNumberGenerator, Sendable {
    func next() -> UInt64 {
        defer { valueQueue.sync { _value += 1 } }
        return valueQueue.sync { _value }
    }

    // MARK: - Private

    nonisolated(unsafe) private var _value: UInt64 = 0
    private let valueQueue = DispatchQueue(label: "value")
}

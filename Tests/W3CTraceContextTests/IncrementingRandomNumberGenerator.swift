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

import Dispatch

/// A random number generator starting at 0 and incrementing by 1 for each generated number.
final class IncrementingRandomNumberGenerator: RandomNumberGenerator, @unchecked Sendable {
    func next() -> UInt64 {
        defer { valueQueue.sync { _value += 1 } }
        return valueQueue.sync { _value }
    }

    // MARK: - Private

    private var _value: UInt64 = 0
    private let valueQueue = DispatchQueue(label: "value")
}

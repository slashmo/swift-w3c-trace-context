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

import XCTest

struct QueueBasedRandomNumberGenerator: RandomNumberGenerator {
    var queue: [UInt64]
    private let file: StaticString
    private let line: UInt

    init(queue: [UInt64], file: StaticString = #file, line: UInt = #line) {
        self.queue = queue
        self.file = file
        self.line = line
    }

    mutating func next() -> UInt64 {
        guard !self.queue.isEmpty else {
            XCTFail("Requested more random numbers than contained in queue", file: self.file, line: self.line)
            preconditionFailure()
        }
        return self.queue.removeFirst()
    }
}

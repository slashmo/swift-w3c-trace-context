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

import W3CTraceContext
import XCTest

final class TraceFlagTests: XCTestCase {
    func test_whenSampled_containsSampledFlag() {
        XCTAssertTrue(TraceFlags.sampled.contains(.sampled))
    }

    func test_whenNotSampled_doesNotContainSampledFlag() {
        XCTAssertFalse(TraceFlags().contains(.sampled))
    }

    func test_description_returnsHexStringRepresentation() {
        XCTAssertEqual("\(TraceFlags.sampled)", "01")
        XCTAssertEqual("\(TraceFlags())", "00")
    }
}

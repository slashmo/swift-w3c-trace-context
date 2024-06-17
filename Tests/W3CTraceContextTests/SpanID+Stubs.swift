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

extension SpanID {
    /// A stubbed `SpanID` with bytes from one to eight.
    static let oneToEight = SpanID(bytes: (1, 2, 3, 4, 5, 6, 7, 8))
}

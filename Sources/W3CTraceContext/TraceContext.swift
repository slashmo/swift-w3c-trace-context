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

public enum W3C {}

extension W3C {
    public struct TraceContext: Equatable {
        public let parent: TraceParent

        public init(parent: TraceParent) {
            self.parent = parent
        }

        public init?(parent parentRawValue: String) {
            guard let parent = TraceParent(rawValue: parentRawValue) else { return nil }
            self.parent = parent
        }
    }
}

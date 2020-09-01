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

extension W3C {
    public struct TraceParent {
        public let traceID: String
        public let parentID: String
        public let traceFlags: String

        public var sampled: Bool {
            self.traceFlags == "01"
        }

        static let version = "00"
    }

    // TODO: Trace State
}

extension W3C.TraceParent: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.traceID == rhs.traceID
            && lhs.parentID == rhs.parentID
    }
}

extension W3C.TraceParent: RawRepresentable {
    public init?(rawValue: String) {
        guard rawValue.count == 55 else { return nil }

        let components = rawValue.split(separator: "-")
        guard components.count == 4 else { return nil }

        // version
        let versionComponent = components[0]
        guard versionComponent == Self.version else { return nil }

        // trace-id
        let traceIDComponent = components[1]
        guard traceIDComponent.count == 32 else { return nil }
        guard traceIDComponent != String(repeating: "0", count: 32) else { return nil }
        self.traceID = String(traceIDComponent)

        // parent-id
        let parentIDComponent = components[2]
        guard parentIDComponent.count == 16 else { return nil }
        guard parentIDComponent != String(repeating: "0", count: 16) else { return nil }
        self.parentID = String(parentIDComponent)

        // trace-flags
        let traceFlagsComponent = components[3]
        guard traceFlagsComponent.count == 2 else { return nil }
        self.traceFlags = String(traceFlagsComponent)
    }

    public var rawValue: String {
        "\(Self.version)-\(self.traceID)-\(self.parentID)-\(self.traceFlags)"
    }
}

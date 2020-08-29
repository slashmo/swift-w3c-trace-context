// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "swift-w3c-trace-context",
    products: [
        .library(name: "W3CTraceContext", targets: ["W3CTraceContext"]),
    ],
    targets: [
        .target(name: "W3CTraceContext"),
        .testTarget(name: "W3CTraceContextTests", dependencies: [
            .target(name: "W3CTraceContext"),
        ]),
    ]
)

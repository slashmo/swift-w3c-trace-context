# W3C Trace Context

[![Swift 5.2](https://img.shields.io/badge/Swift-5.2-ED523F.svg?style=flat)](https://swift.org/download/)
[![CI](https://github.com/slashmo/swift-w3c-trace-context/workflows/CI/badge.svg)](https://github.com/slashmo/swift-w3c-trace-context/actions?query=workflow%3ACI)

This Swift package provides a struct `W3C.TraceContext` conforming to the [W3C Trace Context standard (Level 1)](https://www.w3.org/TR/trace-context).

## Installation

Add the following package dependency to your `Package.swift` file:

```swift
.package(url: "https://github.com/slashmo/swift-w3c-trace-context, .branch("main"))
```

Then, add the `W3CTraceContext` library as a product dependency to each target you want to use it in:

```swift
.product(name: "W3CTraceContext", package: "swift-w3c-trace-context")
```

# W3C Trace Context

[![Swift 5.2](https://img.shields.io/badge/Swift-5.2-ED523F.svg?style=flat)](https://swift.org/download/)
[![CI](https://github.com/slashmo/swift-w3c-trace-context/workflows/CI/badge.svg)](https://github.com/slashmo/swift-w3c-trace-context/actions?query=workflow%3ACI)

This Swift package provides a struct `TraceContext` conforming to
the [W3C Trace Context standard (Level 1)](https://www.w3.org/TR/2020/REC-trace-context-1-20200206/).

## Installation

Add the following package dependency to your `Package.swift` file:

```swift
.package(url: "https://github.com/slashmo/swift-w3c-trace-context", from: "0.5.0")
```

Then, add the `W3CTraceContext` library as a product dependency to each target you want to use it in:

```swift
.product(name: "W3CTraceContext", package: "swift-w3c-trace-context")
```

## Usage

### 1️⃣ Extract raw HTTP header values for `traceparent` and `tracestate`

```swift
let traceParentValue = headers.first(name: TraceParent.headerName)!
let traceStateValue = headers.first(name: TraceState.headerName)!
```

### 2️⃣ Attempt to parse both values, creating a `TraceContext`

```swift
guard let traceContext = TraceContext(parent: traceParentValue, state: traceStateValue) else {
  // received invalid HTTP header values
  return
}
```

### 3️⃣ Inject `traceparent` and `tracestate` into subsequent request headers

```swift
headers.replaceOrAdd(name: TraceParent.headerName, value: traceContext.parent.rawValue)
headers.replaceOrAdd(name: TraceState.headerName, value: traceContext.state.rawValue)
```

## Contributing

Please make sure to run the `./scripts/sanity.sh` script when contributing, it checks formatting and similar things.

You can ensure it always runs and passes before you push by installing a pre-push hook with git:

```sh
echo './scripts/sanity.sh' > .git/hooks/pre-push
```

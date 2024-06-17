# Generate random IDs

Generate unique random span and trace IDs. 

## Overview

Both ``SpanID`` and ``TraceID`` expose static `random` methods to generate ramdom IDs.
Each has two overloads, one defaulting to the `SystemRandomNumberGenerator`,
and one which takes a custom `RandomNumberGenerator`, for example useful for testing.   

### Span ID

```swift
let randomSpanID1 = SpanID.random()

var myGenerator = MyRandomNumberGenerator()
let randomSpanID2 = SpanID.random(using: &myGenerator)
```

- ``SpanID/random()``
- ``SpanID/random(using:)``

### Trace ID

```swift
let randomTraceID1 = TraceID.random()

var myGenerator = MyRandomNumberGenerator()
let randomTraceID2 = TraceID.random(using: &myGenerator)
```

- ``TraceID/random()``
- ``TraceID/random(using:)``

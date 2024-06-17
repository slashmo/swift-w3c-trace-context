# ``W3CTraceContext``

A Swift implementation of the W3C Trace Context standard.

## Overview

`W3CTraceContext` provides building blocks to uniquely identify and serialize distributed traces for
context propagation, implementing the [W3C Trace Context](https://www.w3.org/TR/trace-context-1/) standard.

## Topics

### Trace Context

- <doc:generate-random-ids>
- ``TraceContext``
- ``SpanID``
- ``TraceID``
- ``TraceFlags``
- ``TraceState``

### Decoding headers

- ``TraceParentDecodingError``
- ``TraceStateDecodingError``

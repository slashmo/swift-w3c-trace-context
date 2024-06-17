# Swift W3C Trace Context

[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-brightgreen.svg)](https://swift.org/download)
[![CI](https://github.com/slashmo/swift-w3c-trace-context/actions/workflows/ci.yml/badge.svg)](https://github.com/slashmo/swift-w3c-trace-context/actions/workflows/ci.yml)

A Swift implementation of the [W3C Trace Context](https://www.w3.org/TR/trace-context-1/) standard.

## Contributing

Please make sure to run [`./scripts/soundness.sh`](./scripts/soundness.sh) when contributing.
It checks formatting and similar things.

You can ensure it always runs and passes before you push by installing a pre-push hook with git:

```bash
echo './scripts/soundness.sh' > .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```

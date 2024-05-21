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

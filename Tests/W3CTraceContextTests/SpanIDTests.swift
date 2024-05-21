import W3CTraceContext
import XCTest

final class SpanIDTests: XCTestCase {
    func test_bytes_returnsEightByteArrayRepresentation() {
        let spanID = SpanID(bytes: (1, 2, 3, 4, 5, 6, 7, 8))

        XCTAssertEqual(spanID.bytes, [1, 2, 3, 4, 5, 6, 7, 8])
    }

    func test_equatableConformance() {
        let spanID1 = SpanID(bytes: (1, 2, 3, 4, 5, 6, 7, 8))
        let spanID2 = SpanID(bytes: (1, 2, 3, 4, 5, 6, 7, 0))

        XCTAssertEqual(spanID1, spanID1)
        XCTAssertEqual(spanID2, spanID2)
        XCTAssertNotEqual(spanID1, spanID2)
    }

    func test_hashabilityConformance() {
        let randomSpanIDs = (0 ..< 100).map { _ in SpanID.random() }

        XCTAssertEqual(Set(randomSpanIDs).count, 100)
    }

    func test_identifiableConformance() {
        let randomSpanIDs = (0 ..< 100).map { _ in SpanID.random().id }

        XCTAssertEqual(Set(randomSpanIDs).count, 100)
    }

    func test_description_returnsHexStringRepresentation() {
        let spanID = SpanID(bytes: (0, 10, 20, 50, 100, 150, 200, 255))

        XCTAssertEqual("\(spanID)", "000a14326496c8ff")
    }
}

extension SpanID {
    fileprivate static func random() -> Self {
        SpanID(bytes: (
            .random(in: .min ..< .max),
            .random(in: .min ..< .max),
            .random(in: .min ..< .max),
            .random(in: .min ..< .max),
            .random(in: .min ..< .max),
            .random(in: .min ..< .max),
            .random(in: .min ..< .max),
            .random(in: .min ..< .max)
        ))
    }
}

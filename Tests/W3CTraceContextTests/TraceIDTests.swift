import W3CTraceContext
import XCTest

final class TraceIDTests: XCTestCase {
    func test_bytes_returnsSixteenByteArrayRepresentation() {
        let traceID = TraceID(bytes: (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16))

        XCTAssertEqual(traceID.bytes, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16])
    }

    func test_equatableConformance() {
        let traceID1 = TraceID(bytes: (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16))
        let traceID2 = TraceID(bytes: (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0))

        XCTAssertEqual(traceID1, traceID1)
        XCTAssertEqual(traceID2, traceID2)
        XCTAssertNotEqual(traceID1, traceID2)
    }

    func test_hashabilityConformance() {
        let randomTraceIDs = (0 ..< 100).map { _ in TraceID.random() }

        XCTAssertEqual(Set(randomTraceIDs).count, 100)
    }

    func test_identifiableConformance() {
        let randomTraceIDs = (0 ..< 100).map { _ in TraceID.random().id }

        XCTAssertEqual(Set(randomTraceIDs).count, 100)
    }

    func test_description_returnsHexStringRepresentation() {
        let traceID = TraceID(bytes: (0, 10, 20, 30, 40, 60, 80, 100, 120, 140, 160, 180, 200, 220, 240, 255))

        XCTAssertEqual("\(traceID)", "000a141e283c5064788ca0b4c8dcf0ff")
    }
}

extension TraceID {
    fileprivate static func random() -> Self {
        TraceID(bytes: (
            .random(in: .min ..< .max),
            .random(in: .min ..< .max),
            .random(in: .min ..< .max),
            .random(in: .min ..< .max),
            .random(in: .min ..< .max),
            .random(in: .min ..< .max),
            .random(in: .min ..< .max),
            .random(in: .min ..< .max),
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

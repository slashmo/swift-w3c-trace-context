import W3CTraceContext
import XCTest

final class TraceStateTests: XCTestCase {
    func test_init_withDuplicateVendors_usesLastValueForVendor() {
        let traceState = TraceState([
            (.simple("my-system"), "42"),
            (.simple("other-system"), "42"),
            (.simple("my-system"), "84"),
        ])

        XCTAssertEqual(
            traceState,
            TraceState([
                (.simple("my-system"), "84"),
                (.simple("other-system"), "42"),
            ])
        )
    }

    func test_subscript_previouslyEmpty() {
        var traceState = TraceState()

        let vendor = TraceState.Vendor.simple("my-system")
        let value = "42"
        traceState[vendor] = value

        XCTAssertEqual(Array(traceState), [
            TraceState.Element(vendor: vendor, value: value),
        ])

        XCTAssertEqual(traceState[vendor], value)
    }

    func test_subscript_withNonExistingVendor_returnsNil() {
        var traceState = TraceState()

        let vendor1 = TraceState.Vendor.simple("system-1")
        let vendor2 = TraceState.Vendor.simple("system-2")
        traceState[vendor1] = "42"

        XCTAssertNil(traceState[vendor2])
    }

    func test_subscript_withExistingEntriesForOtherVendors_insertsNewEntryAtTheFront() {
        var traceState = TraceState()

        let vendor1 = TraceState.Vendor.simple("system-1")
        traceState[vendor1] = "42"
        let vendor2 = TraceState.Vendor.simple("system-2")
        traceState[vendor2] = "42"

        XCTAssertEqual(Array(traceState), [
            TraceState.Element(vendor: vendor2, value: "42"),
            TraceState.Element(vendor: vendor1, value: "42"),
        ])
    }

    func test_subscript_updatingValueForExistingVendor_movesUpdatedEntryToTheFront() {
        var traceState = TraceState()

        let vendor1 = TraceState.Vendor.simple("system-1")
        traceState[vendor1] = "42"
        let vendor2 = TraceState.Vendor.simple("system-2")
        traceState[vendor2] = "42"
        traceState[vendor1] = "84"

        XCTAssertEqual(Array(traceState), [
            TraceState.Element(vendor: vendor1, value: "84"),
            TraceState.Element(vendor: vendor2, value: "42"),
        ])
    }

    func test_subscript_withNilValue_withExistingEntryForVendor_removesPreviousEntry() {
        let vendor = TraceState.Vendor.simple("my-system")
        var traceState = TraceState([(vendor, "42")])

        traceState[vendor] = nil

        XCTAssertNil(traceState[vendor])
    }

    func test_vendorDescription_simple() {
        let vendor = TraceState.Vendor.simple("my-system")

        XCTAssertEqual("\(vendor)", "my-system")
    }

    func test_vendorDescription_multiTenant() {
        let vendor = TraceState.Vendor.tenant("42", in: "my-system")

        XCTAssertEqual("\(vendor)", "42@my-system")
    }

    func test_isEmpty_whenEmpty_returnsTrue() {
        let traceState = TraceState()

        XCTAssertTrue(traceState.isEmpty)
    }

    func test_isEmpty_whenNotEmpty_returnsFalse() {
        var traceState = TraceState()
        traceState[.simple("my-system")] = "42"

        XCTAssertFalse(traceState.isEmpty)
    }

    func test_count_returnsNumberOfEntries() {
        var traceState = TraceState()
        XCTAssertEqual(traceState.count, 0)

        traceState[.simple("system-1")] = "42"
        XCTAssertEqual(traceState.count, 1)

        traceState[.simple("system-2")] = "42"
        XCTAssertEqual(traceState.count, 2)
    }

    // MARK: - Decoding

    func test_initDecodingHeaderValue_withSimpleVendor() throws {
        let headerValue = "vendor=value"

        let traceState = try TraceState(decoding: headerValue)

        XCTAssertEqual(Array(traceState), [
            TraceState.Element(vendor: .simple("vendor"), value: "value"),
        ])
    }

    func test_initDecodingHeaderValue_withMultiTenantVendor() throws {
        let headerValue = "tenant@system=value"

        let traceState = try TraceState(decoding: headerValue)

        XCTAssertEqual(Array(traceState), [
            TraceState.Element(vendor: .tenant("tenant", in: "system"), value: "value"),
        ])
    }

    func test_initDecodingHeaderValue_withMultipleEntries() throws {
        let headerValue = "tenant@system=value-1,vendor=value-2"

        let traceState = try TraceState(decoding: headerValue)

        XCTAssertEqual(Array(traceState), [
            TraceState.Element(vendor: .tenant("tenant", in: "system"), value: "value-1"),
            TraceState.Element(vendor: .simple("vendor"), value: "value-2"),
        ])
    }

    func test_initDecodingHeaderValue_withEmptyValue() throws {
        let headerValue = "vendor-1=,vendor-2=value"

        let traceState = try TraceState(decoding: headerValue)

        XCTAssertEqual(Array(traceState), [
            TraceState.Element(vendor: .simple("vendor-1"), value: ""),
            TraceState.Element(vendor: .simple("vendor-2"), value: "value"),
        ])
    }

    func test_initDecodingHeaderValue_withSpacesBetweenDelimiters() throws {
        let headerValue = "vendor-1=foo   , vendor-2=bar"

        let traceState = try TraceState(decoding: headerValue)

        XCTAssertEqual(Array(traceState), [
            TraceState.Element(vendor: .simple("vendor-1"), value: "foo   "),
            TraceState.Element(vendor: .simple("vendor-2"), value: "bar"),
        ])
    }

    func test_initDecodingHeaderValue_withInvalidCharacterInVendorPart_throwsDecodingError() throws {
        let headerValue = "no-Uppercase=value"
        do {
            let traceState = try TraceState(decoding: headerValue)
            XCTFail(#"Expected to catch decoding error, got trace state: "\#(traceState)"."#)
        } catch let error as TraceStateDecodingError {
            XCTAssertEqual(
                error.reason,
                .malformedCharacterInVendor(headerValue.index(headerValue.startIndex, offsetBy: 3))
            )
            XCTAssertEqual(
                error.debugDescription,
                """
                Trace state vendor contains malformed character.
                no-Uppercase=value
                   ^
                """
            )
        }
    }

    func test_initDecodingHeaderValue_withInvalidCharacterInTenantPart_throwsDecodingError() throws {
        let headerValue = "123💩@system=value"
        do {
            let traceState = try TraceState(decoding: headerValue)
            XCTFail(#"Expected to catch decoding error, got trace state: "\#(traceState)"."#)
        } catch let error as TraceStateDecodingError {
            XCTAssertEqual(
                error.reason,
                .malformedCharacterInVendor(headerValue.index(headerValue.startIndex, offsetBy: 3))
            )
            XCTAssertEqual(
                error.debugDescription,
                """
                Trace state vendor contains malformed character.
                123💩@system=value
                   ^
                """
            )
        }
    }

    func test_initDecodingHeaderValue_withInvalidCharacterInSystemPart_throwsDecodingError() throws {
        let headerValue = "tenant@💩=value"
        do {
            let traceState = try TraceState(decoding: headerValue)
            XCTFail(#"Expected to catch decoding error, got trace state: "\#(traceState)"."#)
        } catch let error as TraceStateDecodingError {
            XCTAssertEqual(
                error.reason,
                .malformedCharacterInVendor(headerValue.index(headerValue.startIndex, offsetBy: 7))
            )
            XCTAssertEqual(
                error.debugDescription,
                """
                Trace state vendor contains malformed character.
                tenant@💩=value
                       ^
                """
            )
        }
    }

    func test_initDecodingHeaderValue_withInvalidCharacterInValuePart_throwsDecodingError() throws {
        let headerValue = "vendor=💩"
        do {
            let traceState = try TraceState(decoding: headerValue)
            XCTFail(#"Expected to catch decoding error, got trace state: "\#(traceState)"."#)
        } catch let error as TraceStateDecodingError {
            XCTAssertEqual(
                error.reason,
                .malformedCharacterInValue(headerValue.index(headerValue.startIndex, offsetBy: 7))
            )
            XCTAssertEqual(
                error.debugDescription,
                """
                Trace state value contains malformed character.
                vendor=💩
                       ^
                """
            )
        }
    }

    func test_initDecodingHeaderValue_withTooLongSimpleVendor_throwsDecodingError() throws {
        let maximumAllowedLength = 265
        let invalidVendor = String(repeating: "k", count: maximumAllowedLength + 1)
        let headerValue = "\(invalidVendor)=value"

        do {
            let traceState = try TraceState(decoding: headerValue)
            XCTFail(#"Expected to catch decoding error, got trace state: "\#(traceState)"."#)
        } catch let error as TraceStateDecodingError {
            let lowerBound = headerValue.startIndex
            let upperBound = headerValue.index(headerValue.startIndex, offsetBy: maximumAllowedLength)
            let range = lowerBound ... upperBound
            XCTAssertEqual(error.reason, .simpleVendorTooLong(range))
            XCTAssertEqual(
                error.debugDescription,
                """
                Vendor in trace state exceeds maximum allowed length of 265.
                \(headerValue)
                \(String(repeating: " ", count: maximumAllowedLength))^
                """
            )
        }
    }

    func test_initDecodingHeaderValue_withTooLongTenant_throwsDecodingError() throws {
        let maximumAllowedLength = 241
        let invalidTenant = String(repeating: "t", count: maximumAllowedLength + 1)
        let headerValue = "\(invalidTenant)@system=value"

        do {
            let traceState = try TraceState(decoding: headerValue)
            XCTFail(#"Expected to catch decoding error, got trace state: "\#(traceState)"."#)
        } catch let error as TraceStateDecodingError {
            XCTAssertEqual(
                error.reason,
                .multiTenantVendorTenantTooLong(
                    headerValue.startIndex ... headerValue.index(headerValue.startIndex, offsetBy: maximumAllowedLength)
                )
            )
            XCTAssertEqual(
                error.debugDescription,
                """
                Tenant in trace state exceeds maximum allowed length of 241.
                \(headerValue)
                \(String(repeating: " ", count: maximumAllowedLength))^
                """
            )
        }
    }

    func test_initDecodingHeaderValue_withTooLongSystem_throwsDecodingError() throws {
        let maximumAllowedLength = 14
        let invalidSystem = String(repeating: "s", count: maximumAllowedLength + 1)
        let headerValue = "tenant@\(invalidSystem)=value"

        do {
            let traceState = try TraceState(decoding: headerValue)
            XCTFail(#"Expected to catch decoding error, got trace state: "\#(traceState)"."#)
        } catch let error as TraceStateDecodingError {
            guard case .multiTenantVendorSystemTooLong(let systemRange) = error.reason else {
                return
            }
            XCTAssertEqual(String(headerValue[systemRange]), invalidSystem)
            XCTAssertEqual(
                error.debugDescription,
                """
                Multi-tenant system ID in trace state exceeds maximum allowed length of 241.
                tenant@sssssssssssssss=value
                                     ^
                """
            )
        }
    }

    func test_initDecodingHeaderValue_withTooLongValue_throwsDecodingError() throws {
        let maximumAllowedLength = 265
        let invalidValue = String(repeating: "v", count: maximumAllowedLength + 1)

        do {
            let traceState = try TraceState(decoding: "tenant@system=\(invalidValue)")
            XCTFail(#"Expected to catch decoding error, got trace state: "\#(traceState)"."#)
        } catch let error as TraceStateDecodingError {
            XCTAssertEqual(
                error.reason,
                .valueTooLong(vendor: .tenant("tenant", in: "system"))
            )
            XCTAssertEqual(
                error.debugDescription,
                #"Value for vendor "tenant@system" exceeds maximum allowed length of 265."#
            )
        }
    }
}

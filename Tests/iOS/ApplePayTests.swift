//
//  ApplePayTests.swift
//  Money
//
//  Created by Daniel Thorpe on 16/11/2015.
//
//

import XCTest
import PassKit
@testable import Money

class ApplePayTests: XCTestCase {

    var item: PaymentSummaryItem<GBP>!
    var items: Set<PaymentSummaryItem<GBP>> = []

    override func setUp() {
        super.setUp()
        item = PaymentSummaryItem(cost: 679, label: "iPad Pro, 32GB with WiFi", type: .Final)
        items.insert(item)
    }
}

class PaymentSummaryItemTests: ApplePayTests {

    func test__init__sets_money() {
        XCTAssertEqual(item.cost, 679)
    }

    func test__init__sets_label() {
        XCTAssertEqual(item.label, "iPad Pro, 32GB with WiFi")
    }

    func test__init__sets_type() {
        XCTAssertEqual(item.type, PaymentSummaryItemType.Final)
    }

    func test__set_new_money__sets_money() {
        item = item.setCost(799)
        XCTAssertEqual(item.cost, 799)
        XCTAssertEqual(item.label, "iPad Pro, 32GB with WiFi")
        XCTAssertEqual(item.type, PaymentSummaryItemType.Final)
    }

    func test__set_new_label__sets_label() {
        item = item.setLabel("iPad Pro, 128GB with WiFi")
        XCTAssertEqual(item.cost, 679)
        XCTAssertEqual(item.label, "iPad Pro, 128GB with WiFi")
        XCTAssertEqual(item.type, PaymentSummaryItemType.Final)
    }

    func test__set_new_type__sets_type() {
        item = item.setType(.Pending)
        XCTAssertEqual(item.cost, 679)
        XCTAssertEqual(item.label, "iPad Pro, 32GB with WiFi")
        XCTAssertEqual(item.type, PaymentSummaryItemType.Pending)
    }

    func test__equality() {
        XCTAssertEqual(item, PaymentSummaryItem<GBP>(cost: 679, label: "iPad Pro, 32GB with WiFi", type: .Final))
        XCTAssertNotEqual(item, PaymentSummaryItem<GBP>(cost: 799, label: "iPad Pro, 128GB with WiFi", type: .Final))
    }
}

class PaymentSummaryItemCodingTests: ApplePayTests {

    func archiveEncoded() -> NSData {
        return NSKeyedArchiver.archivedDataWithRootObject(item.encoded)
    }

    func unarchive(archive: NSData) -> PaymentSummaryItem<GBP>? {
        return PaymentSummaryItem<GBP>.decode(NSKeyedUnarchiver.unarchiveObjectWithData(archive))
    }

    func test__encode_decode() {
        XCTAssertEqual(unarchive(archiveEncoded()), item)
    }
}

class PKPaymentSummaryItemTypeTests: ApplePayTests {

    func test__init__final() {
        let type = PKPaymentSummaryItemType(paymentSummaryItemType: .Final)
        XCTAssertEqual(type, PKPaymentSummaryItemType.Final)
    }

    func test__init__pending() {
        let type = PKPaymentSummaryItemType(paymentSummaryItemType: .Pending)
        XCTAssertEqual(type, PKPaymentSummaryItemType.Pending)
    }
}

class PKPaymentSummaryItemTests: ApplePayTests {

    func test__init__with_item() {
        let summaryItem = PKPaymentSummaryItem(paymentSummaryItem: item)
        XCTAssertEqual(summaryItem.amount, NSDecimalNumber(integer: 679))
        XCTAssertEqual(summaryItem.label, "iPad Pro, 32GB with WiFi")
        XCTAssertEqual(summaryItem.type, PKPaymentSummaryItemType.Final)
    }
}

class PKPaymentRequestTests: ApplePayTests {

    func test__init__with_items() {
        items.insert(PaymentSummaryItem(cost: 799, label: "iPad Pro, 128GB with WiFi", type: .Final))
        items.insert(PaymentSummaryItem(cost: 899, label: "iPad Pro, 128GB with WiFi + Cellular", type: .Final))
        let request = PKPaymentRequest(items: items)
        XCTAssertEqual(request.currencyCode, GBP.Currency.code)
        XCTAssertEqual(request.paymentSummaryItems.count, 3)
        let total = request.paymentSummaryItems.reduce(NSDecimalNumber.zero()) { (acc, item) in
            return acc.decimalNumberByAdding(item.amount)
        }

        XCTAssertEqual(total, items.map { $0.cost }.reduce(0, combine: +).amount)
    }
}

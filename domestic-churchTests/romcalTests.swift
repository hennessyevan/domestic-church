//
//  domestic_churchTests.swift
//  domestic-churchTests
//
//  Created by Evan Hennessy on 2023-08-25.
//

import XCTest

final class romcalTests: XCTestCase {
	let romcal = Romcal()

	func testExample() throws {
		let today = romcal.today

		print(today)

		XCTAssertNotNil(today)
	}
}

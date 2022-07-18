//
//  InstagramTests.swift
//  InstagramTests
//
//  Created by Caleb Ngai on 6/27/22.
//

import XCTest
@testable import Instagram

class InstagramTests: XCTestCase {
    
    func testNotificationIDCreation() {
        let first = NotificationsManager.newIdentifier()
        let second = NotificationsManager.newIdentifier()
        XCTAssertNotEqual(first, second)
    }
}

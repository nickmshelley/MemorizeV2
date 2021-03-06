//
//  DateHelperTests.swift
//  MemorizeTests
//
//  Created by Heather Shelley on 5/20/18.
//

import XCTest
@testable import Memorize

class DateHelperTests: XCTestCase {
    func testThreeAMToday() {
        let testDate1 = DateHelpers.threeAM()
        sleep(3)
        let testDate2 = DateHelpers.threeAM()
        
        XCTAssertEqual(testDate1, testDate2)
        
        let calendar = Calendar.autoupdatingCurrent
        let testComps = calendar.dateComponents([.hour, .day], from: testDate1)
        XCTAssertEqual(testComps.hour!, 3)
        let todayDay = calendar.dateComponents([.day], from: Date()).day!
        XCTAssertEqual(testComps.day!, todayDay)
    }
}

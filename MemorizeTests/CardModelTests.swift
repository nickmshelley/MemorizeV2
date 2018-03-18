//
//  CardModelTests.swift
//  MemorizeTests
//
//  Created by Heather Shelley on 3/18/18.
//

import XCTest
@testable import Memorize

class CardModelTests: XCTestCase {
    func testNeedsReview() {
        let before = Date().addingTimeInterval(-20)
        let after = Date().addingTimeInterval(20)
        let review = createCardWithNextReviewDate(before)
        let notReview = createCardWithNextReviewDate(after)
        
        XCTAssertTrue(review.needsNormalReview())
        XCTAssertTrue(review.needsReverseReview())
        XCTAssertFalse(notReview.needsNormalReview())
        XCTAssertFalse(notReview.needsReverseReview())
    }
    
    func testDayDifference() {
        let zero = createCardWithSuccessCount(0)
        let one = createCardWithSuccessCount(1)
        let two = createCardWithSuccessCount(2)
        let five = createCardWithSuccessCount(5)
        let ten = createCardWithSuccessCount(10)
        let aLot = createCardWithSuccessCount(1000)
        
        XCTAssertEqual(zero.normalDayDifference(), 1)
        XCTAssertEqual(one.normalDayDifference(), 1)
        XCTAssertEqual(two.normalDayDifference(), 4)
        XCTAssertEqual(five.normalDayDifference(), 25)
        XCTAssertEqual(ten.normalDayDifference(), 100)
        XCTAssertEqual(aLot.normalDayDifference(), 100)
        
        XCTAssertEqual(zero.reverseDayDifference(), 1)
        XCTAssertEqual(one.reverseDayDifference(), 1)
        XCTAssertEqual(two.reverseDayDifference(), 4)
        XCTAssertEqual(five.reverseDayDifference(), 25)
        XCTAssertEqual(ten.reverseDayDifference(), 100)
        XCTAssertEqual(aLot.reverseDayDifference(), 100)
        
    }
}

extension CardModelTests {
    func createCardWithNextReviewDate(_ date: Date) -> Card {
        return Card(id: "", question: "", answer: "", isReviewing: true, normalSuccessCount: 0, reverseSuccessCount: 0, normalNextReviewDate: date, reverseNextReviewDate: date)
    }
    
    func createCardWithSuccessCount(_ count: Int) -> Card {
        return Card(id: "", question: "", answer: "", isReviewing: true, normalSuccessCount: count, reverseSuccessCount: count, normalNextReviewDate: nil, reverseNextReviewDate: nil)
    }
}

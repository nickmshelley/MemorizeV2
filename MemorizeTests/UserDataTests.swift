//
//  MemorizeTests.swift
//  MemorizeTests
//
//  Created by Nick Shelley on 1/12/18.
//

import XCTest
@testable import Memorize

class UserDataTests: XCTestCase {
    func testAllCards() {
        let db = UserDataController(path: nil)!
        
        try! db.createCard(question: "C", answer: "D")
        try! db.createCard(question: "A", answer: "B")
        
        let cards = db.allCards()
        XCTAssertEqual(cards.count, 2)
        XCTAssertEqual(cards[0].question, "A")
        XCTAssertEqual(cards[0].answer, "B")
        XCTAssertEqual(cards[1].question, "C")
        XCTAssertEqual(cards[1].answer, "D")
    }
    
    func testReviewingCards() {
        let db = UserDataController(path: nil)!
        
        try! db.createCard(question: "C", answer: "D", isReviewing: true)
        try! db.createCard(question: "A", answer: "B", isReviewing: false)
        
        let reviewingCards = db.reviewingCards()
        XCTAssertEqual(reviewingCards.count, 1)
        XCTAssertEqual(reviewingCards.first?.question, "C")
    }
    
    func testTodaysCards() {
        let db = UserDataController(path: nil)!
        
        let before = Date().addingTimeInterval(-20)
        let moreBefore = Date().addingTimeInterval(-40)
        
        let moreBeforeIDsOne = (1...2).map { _ in createCardWithNextReview(moreBefore, successCount: 1, db: db) }.sorted()
        let moreBeforeIDsTwo = (1...2).map { _ in createCardWithNextReview(moreBefore, successCount: 2, db: db) }.sorted()
        let moreBeforeIDsThree = (1...2).map { _ in createCardWithNextReview(moreBefore, successCount: 3, db: db) }.sorted()
        
        let beforeIDsOne = (1...2).map { _ in createCardWithNextReview(before, successCount: 1, db: db) }.sorted()
        let beforeIDsTwo = (1...2).map { _ in createCardWithNextReview(before, successCount: 2, db: db) }.sorted()
        let beforeIDsThree = (1...2).map { _ in createCardWithNextReview(before, successCount: 3, db: db) }.sorted()
        
        // Normal
        let normalExpectedOne = [moreBeforeIDsOne[0]]
        let normalExpectedTwo = normalExpectedOne + [moreBeforeIDsTwo[0]]
        let normalExpectedThree = normalExpectedTwo + [moreBeforeIDsThree[0]]
        let normalExpectedFour = normalExpectedThree + [beforeIDsOne[0]]
        let normalExpectedFive = normalExpectedFour + [beforeIDsTwo[0]]
        let normalExpectedSix = normalExpectedFive + [beforeIDsThree[0]]
        let normalExpectedSeven = normalExpectedSix + [moreBeforeIDsOne[1]]
        let normalExpectedEight = normalExpectedSeven + [moreBeforeIDsTwo[1]]
        
        let normalExpecteds = [normalExpectedOne, normalExpectedTwo, normalExpectedThree, normalExpectedFour, normalExpectedFive, normalExpectedSix, normalExpectedSeven, normalExpectedEight]
        let normalActuals = (1...8).map { db.todaysNormalReviewCards(perDay: $0).map({ $0.id }) }
        
        XCTAssertEqual(normalExpecteds, normalActuals)
        
        // Reverse
        let reverseExpectedOne = [moreBeforeIDsOne[0]]
        let reverseExpectedTwo = reverseExpectedOne + [moreBeforeIDsTwo[0]]
        let reverseExpectedThree = reverseExpectedTwo + [moreBeforeIDsThree[0]]
        let reverseExpectedFour = reverseExpectedThree + [beforeIDsOne[0]]
        let reverseExpectedFive = reverseExpectedFour + [beforeIDsTwo[0]]
        let reverseExpectedSix = reverseExpectedFive + [beforeIDsThree[0]]
        let reverseExpectedSeven = reverseExpectedSix + [moreBeforeIDsOne[1]]
        let reverseExpectedEight = reverseExpectedSeven + [moreBeforeIDsTwo[1]]
        
        let reverseExpecteds = [reverseExpectedOne, reverseExpectedTwo, reverseExpectedThree, reverseExpectedFour, reverseExpectedFive, reverseExpectedSix, reverseExpectedSeven, reverseExpectedEight]
        let reverseActuals = (1...8).map { db.todaysReverseReviewCards(perDay: $0).map({ $0.id }) }
        
        XCTAssertEqual(reverseExpecteds, reverseActuals)
    }
}

extension UserDataTests {
    func createCardWithNextReview(_ nextReview: Date, successCount: Int, db: UserDataController) -> String {
        let id = NSUUID().uuidString
        try! db.createCard(id: id, question: "A", answer: "B", isReviewing: true, normalSuccessCount: successCount, reverseSuccessCount: successCount, normalNextReviewDate: nextReview, reverseNextReviewDate: nextReview)
        
        return id
    }
}

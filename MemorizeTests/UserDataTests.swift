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
    
    func testCardsReadyToReview() {
        let db = UserDataController(path: nil)!
        
        let before = Date().addingTimeInterval(-20)
        let after = Date().addingTimeInterval(20)
        
        let expected = Set((1...3).map { _ in createCardWithNextReview(before, successCount: 3, db: db) })
        (1...2).forEach { _ in createCardWithNextReview(after, successCount: 3, db: db) }
        
        let normalActual = Set(db.normalReadyToReviewCards().map { $0.id })
        let reverseActual = Set(db.reverseReadyToReviewCards().map { $0.id })
        
        XCTAssertEqual(Set(expected), normalActual)
        XCTAssertEqual(Set(expected), reverseActual)
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
        
        // Normal
        let normalExpectedOne = [moreBeforeIDsOne[0]]
        let normalExpectedTwo = normalExpectedOne + [moreBeforeIDsTwo[0]]
        let normalExpectedThree = normalExpectedTwo + [moreBeforeIDsThree[0]]
        let normalExpectedFour = normalExpectedThree + [moreBeforeIDsOne[1]]
        let normalExpectedFive = normalExpectedFour + [moreBeforeIDsTwo[1]]
        let normalExpectedSix = normalExpectedFive + [moreBeforeIDsThree[1]]
        let normalExpectedSeven = normalExpectedSix + [beforeIDsOne[0]]
        let normalExpectedEight = normalExpectedSeven + [beforeIDsTwo[0]]
        
        let normalExpecteds = [normalExpectedOne, normalExpectedTwo, normalExpectedThree, normalExpectedFour, normalExpectedFive, normalExpectedSix, normalExpectedSeven, normalExpectedEight]
        let normalActuals = (1...8).map { db.todaysNormalReviewCards(perDay: $0).map({ $0.id }) }
        
        XCTAssertEqual(normalExpecteds, normalActuals)
        
        // Reverse
        let reverseExpectedOne = [moreBeforeIDsOne[0]]
        let reverseExpectedTwo = reverseExpectedOne + [moreBeforeIDsTwo[0]]
        let reverseExpectedThree = reverseExpectedTwo + [moreBeforeIDsThree[0]]
        let reverseExpectedFour = reverseExpectedThree + [moreBeforeIDsOne[1]]
        let reverseExpectedFive = reverseExpectedFour + [moreBeforeIDsTwo[1]]
        let reverseExpectedSix = reverseExpectedFive + [moreBeforeIDsThree[1]]
        let reverseExpectedSeven = reverseExpectedSix + [beforeIDsOne[0]]
        let reverseExpectedEight = reverseExpectedSeven + [beforeIDsTwo[0]]
        
        let reverseExpecteds = [reverseExpectedOne, reverseExpectedTwo, reverseExpectedThree, reverseExpectedFour, reverseExpectedFive, reverseExpectedSix, reverseExpectedSeven, reverseExpectedEight]
        let reverseActuals = (1...8).map { db.todaysReverseReviewCards(perDay: $0).map({ $0.id }) }
        
        XCTAssertEqual(reverseExpecteds, reverseActuals)
    }
    
    func testUpdate() {
        let db = UserDataController(path: nil)!
        let needsReview = Date().addingTimeInterval(-50)
        
        let date1 = Date().addingTimeInterval(30)
        let date2 = Date().addingTimeInterval(100)
        
        let id = createCardWithNextReview(needsReview, successCount: 1, db: db)
        try! db.updateNormalReview(ofCardWithID: id, nextReview: date1, successCount: 5)
        try! db.updateReverseReview(ofCardWithID: id, nextReview: date2, successCount: 8)
        
        let card = try! db.card(withID: id)!
        XCTAssertEqual(card.normalSuccessCount, 5)
        XCTAssertEqual(card.normalNextReviewDate!.timeIntervalSince1970, date1.timeIntervalSince1970, accuracy: 0.001)
        XCTAssertEqual(card.reverseSuccessCount, 8)
        XCTAssertEqual(card.reverseNextReviewDate!.timeIntervalSince1970, date2.timeIntervalSince1970, accuracy: 0.001)
    }
}

extension UserDataTests {
    @discardableResult
    func createCardWithNextReview(_ nextReview: Date, successCount: Int, db: UserDataController) -> String {
        let id = NSUUID().uuidString
        try! db.createCard(id: id, question: "A", answer: "B", isReviewing: true, normalSuccessCount: successCount, reverseSuccessCount: successCount, normalNextReviewDate: nextReview, reverseNextReviewDate: nextReview)
        
        return id
    }
}

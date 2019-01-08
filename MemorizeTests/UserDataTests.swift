//
//  MemorizeTests.swift
//  MemorizeTests
//
//  Created by Nick Shelley on 1/12/18.
//

import XCTest
@testable import Memorize

class UserDataTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        SettingsController.normalReviewedToday = 0
        SettingsController.reverseReviewedToday = 0
    }
    
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
    
    func testDelete() {
        let db = UserDataController(path: nil)!
        
        let id1 = try! db.createCard(question: "C", answer: "D")
        let id2 = try! db.createCard(question: "A", answer: "B")
        
        XCTAssertEqual(db.allCards().map { $0.id }.sorted(), [id1, id2].sorted())
        
        try! db.deleteCard(withID: id1)
        XCTAssertNil(try! db.card(withID: id1))
        XCTAssertEqual(db.allCards().map { $0.id }, [id2])
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
        
        let moreBeforeIDOne = createCardWithNextReview(moreBefore, successCount: 1, db: db)
        let moreBeforeIDTwo = createCardWithNextReview(moreBefore, successCount: 2, db: db)
        let moreBeforeIDThree = createCardWithNextReview(moreBefore, successCount: 3, db: db)
        
        let beforeIDOne = createCardWithNextReview(before, successCount: 1, db: db)
        let beforeIDTwo = createCardWithNextReview(before, successCount: 2, db: db)
        
        XCTAssertEqual(db.todaysNormalReviewCards(perDay: 10).count, 5)
        XCTAssertEqual(db.todaysReverseReviewCards(perDay: 10).count, 5)
        
        SettingsController.normalReviewedToday = 3
        SettingsController.reverseReviewedToday = 2
        XCTAssertEqual(db.todaysNormalReviewCards(perDay: 5).count, 2)
        XCTAssertEqual(db.todaysReverseReviewCards(perDay: 5).count, 3)
        XCTAssertEqual(db.todaysNormalReviewCards(perDay: 5, force: true).count, 5)
        XCTAssertEqual(db.todaysReverseReviewCards(perDay: 5, force: true).count, 5)
        
        SettingsController.reverseReviewedToday = 0
        SettingsController.normalReviewedToday = 0
        
        // Normal
        let normalExpectedOne = [moreBeforeIDOne]
        let normalExpectedTwo = normalExpectedOne + [moreBeforeIDTwo]
        let normalExpectedThree = normalExpectedTwo + [moreBeforeIDThree]
        let normalExpectedFour = normalExpectedThree + [beforeIDOne]
        let normalExpectedFive = normalExpectedFour + [beforeIDTwo]
        
        let expecteds = [normalExpectedOne, normalExpectedTwo, normalExpectedThree, normalExpectedFour, normalExpectedFive].map { Set($0) }
        let normalActuals = (1...5).map { db.todaysNormalReviewCards(perDay: $0).map({ $0.id }) }.map { Set($0) }
        XCTAssertEqual(expecteds, normalActuals)
        
        // Reverse
        let reverseActuals = (1...5).map { db.todaysReverseReviewCards(perDay: $0).map({ $0.id }) }.map { Set($0) }
        XCTAssertEqual(expecteds, reverseActuals)
    }
    
    func testTodayMaxDayDifference() {
        let db = UserDataController(path: nil)!
        let before = Date().addingTimeInterval(-20)
        
        let oneIDOne = createCardWithNextReview(before, successCount: 1, db: db)
        let oneIDTwo = createCardWithNextReview(before, successCount: 1, db: db)
        let tenID = createCardWithNextReview(before, successCount: 10, db: db)
        let elevenID = createCardWithNextReview(before, successCount: 11, db: db)
        
        let normalActual = db.todaysNormalReviewCards(perDay: 3).map { $0.id }
        XCTAssert(normalActual.contains(oneIDOne))
        XCTAssert(normalActual.contains(oneIDTwo))
        XCTAssertEqual(normalActual.count, 3)
        
        let normalTenExpectation = XCTestExpectation(description: "Normal Ten")
        let normalElevenExpectation = XCTestExpectation(description: "Normal Eleven")
        for _ in 0...100 {
            let actual = db.todaysNormalReviewCards(perDay: 3).map { $0.id }
            if actual.contains(tenID) {
                normalTenExpectation.fulfill()
            }
            if actual.contains(elevenID) {
                normalElevenExpectation.fulfill()
            }
        }
        
        let reverseActual = db.todaysReverseReviewCards(perDay: 3).map { $0.id }
        XCTAssert(reverseActual.contains(oneIDOne))
        XCTAssert(reverseActual.contains(oneIDTwo))
        XCTAssertEqual(reverseActual.count, 3)
        
        let reverseTenExpectation = XCTestExpectation(description: "Reverse Ten")
        let reverseElevenExpectation = XCTestExpectation(description: "Reverse Eleven")
        for _ in 0...100 {
            let actual = db.todaysReverseReviewCards(perDay: 3).map { $0.id }
            if actual.contains(tenID) {
                reverseTenExpectation.fulfill()
            }
            if actual.contains(elevenID) {
                reverseElevenExpectation.fulfill()
            }
        }
        
        wait(for: [normalTenExpectation, normalElevenExpectation, reverseTenExpectation, reverseElevenExpectation], timeout: 0)
    }
    
    func testUpdate() {
        let db = UserDataController(path: nil)!
        let needsReview = Date().addingTimeInterval(-50)
        
        let date1 = Date().addingTimeInterval(30)
        let date2 = Date().addingTimeInterval(100)
        
        let id = createCardWithNextReview(needsReview, successCount: 1, db: db)
        try! db.updateNormalReview(ofCardWithID: id, nextReview: date1, successCount: 5)
        try! db.updateReverseReview(ofCardWithID: id, nextReview: date2, successCount: 8)
        
        var card = try! db.card(withID: id)!
        XCTAssertEqual(card.normalSuccessCount, 5)
        XCTAssertEqual(card.normalNextReviewDate!.timeIntervalSince1970, date1.timeIntervalSince1970, accuracy: 0.001)
        XCTAssertEqual(card.reverseSuccessCount, 8)
        XCTAssertEqual(card.reverseNextReviewDate!.timeIntervalSince1970, date2.timeIntervalSince1970, accuracy: 0.001)
        
        try! db.updateNormalReviewMissed(ofCardWithID: id)
        try! db.updateReverseReviewMissed(ofCardWithID: id)
        
        card = try! db.card(withID: id)!
        XCTAssertEqual(card.normalSuccessCount, 0)
        XCTAssertEqual(card.reverseSuccessCount, 0)
    }
    
    func testUpdateText() {
        let db = UserDataController(path: nil)!
        let id = createCardWithNextReview(Date(), successCount: 1, db: db)
        var card = try! db.card(withID: id)!
        XCTAssertEqual(card.question, "A")
        XCTAssertEqual(card.answer, "B")
        
        try! db.updateCardWithID(id, question: "c", answer: "D")
        card = try! db.card(withID: id)!
        XCTAssertEqual(card.question, "c")
        XCTAssertEqual(card.answer, "D")
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

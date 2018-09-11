//
//  ReviewViewModelTests.swift
//  MemorizeTests
//
//  Created by Nick Shelley on 5/7/18.
//

import XCTest
@testable import Memorize

class ReviewViewModelTests: XCTestCase {
    func testInit() {
        UserDataController.shared = UserDataController(path: nil)
        let needsReview = Date().addingTimeInterval(-50)
        let futureReview = Date().addingTimeInterval(50)
        createCard(normalNextReview: needsReview, reverseNextReview: needsReview)
        createCard(normalNextReview: needsReview, reverseNextReview: futureReview)
        
        var vm = ReviewViewModel()
        XCTAssertEqual(vm.remaining, 2)
        XCTAssertTrue(vm.isNormal)
        
        UserDataController.shared = UserDataController(path: nil)
        createCard(normalNextReview: futureReview, reverseNextReview: needsReview)
        vm = ReviewViewModel()
        XCTAssertEqual(vm.remaining, 1)
        XCTAssertFalse(vm.isNormal)
        XCTAssertEqual(vm.question, "A")
        XCTAssertEqual(vm.answer, "B")
    }
    
    func testCorrect() {
        UserDataController.shared = UserDataController(path: nil)
        let needsReview = Date().addingTimeInterval(-50)
        createCard(normalNextReview: needsReview, reverseNextReview: needsReview)
        createCard(normalNextReview: needsReview, reverseNextReview: needsReview)
        let nextDate = DateHelpers.threeAM().addingTimeInterval(24 * 60 * 60)
        
        let vm = ReviewViewModel()
        XCTAssertTrue(vm.isNormal)
        XCTAssertEqual(vm.remaining, 2)
        
        var beforeID = vm.currentCard!.id
        vm.correct()
        XCTAssertEqual(vm.remaining, 1)
        XCTAssertNotEqual(vm.currentCard!.id, beforeID)
        XCTAssertFalse(UserDataController.shared!.normalReadyToReviewCards().contains { $0.id == beforeID })
        var card = try! UserDataController.shared?.card(withID: beforeID)
        XCTAssertEqual(nextDate.timeIntervalSince1970, card!.normalNextReviewDate!.timeIntervalSince1970, accuracy: 0.001)
        
        beforeID = vm.currentCard!.id
        vm.correct()
        XCTAssertFalse(vm.isNormal)
        XCTAssertEqual(vm.remaining, 2)
        XCTAssertFalse(UserDataController.shared!.normalReadyToReviewCards().contains { $0.id == beforeID })
        card = try! UserDataController.shared?.card(withID: beforeID)
        XCTAssertEqual(nextDate.timeIntervalSince1970, card!.normalNextReviewDate!.timeIntervalSince1970, accuracy: 0.001)
        
        beforeID = vm.currentCard!.id
        vm.correct()
        XCTAssertEqual(vm.remaining, 1)
        XCTAssertNotEqual(vm.currentCard!.id, beforeID)
        XCTAssertFalse(UserDataController.shared!.reverseReadyToReviewCards().contains { $0.id == beforeID })
        card = try! UserDataController.shared?.card(withID: beforeID)
        XCTAssertEqual(nextDate.timeIntervalSince1970, card!.reverseNextReviewDate!.timeIntervalSince1970, accuracy: 0.001)

        beforeID = vm.currentCard!.id
        vm.correct()
        XCTAssertEqual(vm.remaining, 0)
        XCTAssertFalse(UserDataController.shared!.reverseReadyToReviewCards().contains { $0.id == beforeID })
        card = try! UserDataController.shared?.card(withID: beforeID)
        XCTAssertEqual(nextDate.timeIntervalSince1970, card!.reverseNextReviewDate!.timeIntervalSince1970, accuracy: 0.001)

        XCTAssertNil(vm.currentCard)
    }
    
    func testMissed() {
        UserDataController.shared = UserDataController(path: nil)
        let needsReview = Date().addingTimeInterval(-50)
        createCard(normalNextReview: needsReview, reverseNextReview: needsReview)
        createCard(normalNextReview: needsReview, reverseNextReview: needsReview)
        
        let vm = ReviewViewModel()
        XCTAssertTrue(vm.isNormal)
        XCTAssertEqual(vm.remaining, 2)
        
        var missed = UserDataController.shared!.normalReadyToReviewCards().filter { $0.normalSuccessCount == 0 }
        XCTAssertEqual(missed.count, 0)
        
        vm.missed()
        vm.missed()
        
        missed = UserDataController.shared!.normalReadyToReviewCards().filter { $0.normalSuccessCount == 0 }
        XCTAssertEqual(missed.count, 2)
        
        var beforeID = vm.currentCard!.id
        for _ in 1...100 {
            vm.missed()
            XCTAssertNotEqual(vm.currentCard!.id, beforeID)
            beforeID = vm.currentCard!.id
        }
    }
    
    func testMissedThenCorrect() {
        UserDataController.shared = UserDataController(path: nil)
        let needsReview = Date().addingTimeInterval(-50)
        createCard(normalNextReview: needsReview, reverseNextReview: needsReview, successCount: 3)
        let vm = ReviewViewModel()
        let nextDate = DateHelpers.threeAM().addingTimeInterval(24 * 60 * 60)
        
        vm.missed()
        vm.correct()
        let card = UserDataController.shared?.allCards().first!
        XCTAssertEqual(card?.normalNextReviewDate!, nextDate)
    }
    
    func testUndoSingle() {
        UserDataController.shared = UserDataController(path: nil)
        let dc = UserDataController.shared
        let needsReview = Date().addingTimeInterval(-50)
        createCard(normalNextReview: needsReview, reverseNextReview: needsReview, successCount: 3)
        let vm = ReviewViewModel()
        let originalCard = vm.currentCard!
        let nextDate = DateHelpers.threeAM().addingTimeInterval(24 * 60 * 60 * 9)
        
        vm.correct()
        XCTAssertEqual(try! dc?.card(withID: originalCard.id)?.normalNextReviewDate, nextDate)
        XCTAssertFalse(vm.isNormal)
        vm.undo()
        XCTAssertEqual(vm.currentCard, originalCard)
        XCTAssertEqual(try! dc?.card(withID: originalCard.id), originalCard)
        XCTAssertTrue(vm.isNormal)
        
        vm.missed()
        XCTAssertEqual(try! dc?.card(withID: originalCard.id)?.normalSuccessCount, 0)
        vm.undo()
        XCTAssertEqual(vm.currentCard, originalCard)
        XCTAssertEqual(try! dc?.card(withID: originalCard.id), originalCard)
        
        vm.correct()
        vm.correct()
        var card = try! dc?.card(withID: originalCard.id)
        XCTAssertEqual(vm.remaining, 0)
        XCTAssertEqual(card?.normalNextReviewDate, nextDate)
        XCTAssertEqual(card?.reverseNextReviewDate, nextDate)
        XCTAssertEqual(card?.normalSuccessCount, 4)
        XCTAssertEqual(card?.reverseSuccessCount, 4)
        vm.undo()
        card = try! dc?.card(withID: originalCard.id)
        XCTAssertEqual(card?.normalNextReviewDate, nextDate)
        XCTAssertEqual(card?.reverseNextReviewDate, originalCard.reverseNextReviewDate)
        XCTAssertEqual(card?.normalSuccessCount, 4)
        XCTAssertEqual(card?.reverseSuccessCount, 3)
        XCTAssertEqual(vm.remaining, 1)
        XCTAssertFalse(vm.isNormal)
        vm.undo()
        XCTAssertEqual(vm.currentCard, originalCard)
        XCTAssertEqual(try! dc?.card(withID: originalCard.id), originalCard)
        XCTAssertEqual(vm.remaining, 1)
        XCTAssertTrue(vm.isNormal)
    }
    
    func testUndo() {
        UserDataController.shared = UserDataController(path: nil)
        let needsReview = Date().addingTimeInterval(-50)
        createCard(normalNextReview: needsReview, reverseNextReview: needsReview, successCount: 3)
        createCard(normalNextReview: needsReview, reverseNextReview: needsReview, successCount: 3)
        createCard(normalNextReview: needsReview, reverseNextReview: needsReview, successCount: 3)
        createCard(normalNextReview: needsReview, reverseNextReview: needsReview, successCount: 3)
        let vm = ReviewViewModel()
        let originalCards = UserDataController.shared?.allCards()
        let originalDate = originalCards?.first?.normalNextReviewDate
        let nextDateMissed = DateHelpers.threeAM().addingTimeInterval(24 * 60 * 60)
        
        var ids: [String] = []
        // normal
        for _ in 1...100 {
            ids.append(vm.currentCard!.id)
            vm.missed()
        }
        var remaining = 4
        for _ in 1...4 {
            ids.append(vm.currentCard!.id)
            XCTAssertEqual(vm.remaining, remaining)
            vm.correct()
            remaining -= 1
        }
        XCTAssertEqual(vm.remaining, 4)
        XCTAssertFalse(vm.isNormal)
        
        // reverse
        for _ in 1...100 {
            ids.append(vm.currentCard!.id)
            vm.missed()
        }
        remaining = 4
        for _ in 1...4 {
            ids.append(vm.currentCard!.id)
            XCTAssertEqual(vm.remaining, remaining)
            vm.correct()
            remaining -= 1
        }
        XCTAssertEqual(vm.remaining, 0)
        
        var cards = UserDataController.shared?.allCards()
        XCTAssertFalse(cards!.contains(where: { $0.normalNextReviewDate != nextDateMissed }))
        XCTAssertFalse(cards!.contains(where: { $0.reverseNextReviewDate != nextDateMissed }))
        XCTAssertFalse(cards!.contains(where: { $0.normalSuccessCount != 1 }))
        XCTAssertFalse(cards!.contains(where: { $0.reverseSuccessCount != 1 }))
        
        for _ in 1...104 {
            vm.undo()
            XCTAssertFalse(vm.isNormal)
            XCTAssertEqual(vm.currentCard?.id, ids.popLast())
        }
        cards = UserDataController.shared?.allCards()
        XCTAssertFalse(cards!.contains(where: { $0.normalNextReviewDate != nextDateMissed }))
        XCTAssertFalse(cards!.contains(where: { $0.reverseNextReviewDate != originalDate }))
        XCTAssertFalse(cards!.contains(where: { $0.normalSuccessCount != 1 }))
        XCTAssertFalse(cards!.contains(where: { $0.reverseSuccessCount != 3 }))
        
        for _ in 1...104 {
            vm.undo()
            XCTAssertTrue(vm.isNormal)
            XCTAssertEqual(vm.currentCard?.id, ids.popLast())
        }
        XCTAssertEqual(ids.count, 0)
        XCTAssertEqual(originalCards, UserDataController.shared?.allCards())
    }
}

extension ReviewViewModelTests {
    @discardableResult
    func createCard(normalNextReview: Date, reverseNextReview: Date, successCount: Int = 1) -> String {
        let id = NSUUID().uuidString
        try! UserDataController.shared!.createCard(id: id, question: "A", answer: "B", isReviewing: true, normalSuccessCount: successCount, reverseSuccessCount: successCount, normalNextReviewDate: normalNextReview, reverseNextReviewDate: reverseNextReview)
        
        return id
    }
}

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
        
        let vm = ReviewViewModel()
        XCTAssertTrue(vm.isNormal)
        XCTAssertEqual(vm.remaining, 2)
        
        var beforeID = vm.currentCard!.id
        vm.correct()
        XCTAssertEqual(vm.remaining, 1)
        XCTAssertNotEqual(vm.currentCard!.id, beforeID)
        XCTAssertFalse(UserDataController.shared!.normalReadyToReviewCards().contains { $0.id == beforeID })
        
        beforeID = vm.currentCard!.id
        vm.correct()
        XCTAssertFalse(vm.isNormal)
        XCTAssertEqual(vm.remaining, 2)
        XCTAssertFalse(UserDataController.shared!.normalReadyToReviewCards().contains { $0.id == beforeID })
        
        beforeID = vm.currentCard!.id
        vm.correct()
        XCTAssertEqual(vm.remaining, 1)
        XCTAssertNotEqual(vm.currentCard!.id, beforeID)
        XCTAssertFalse(UserDataController.shared!.reverseReadyToReviewCards().contains { $0.id == beforeID })

        beforeID = vm.currentCard!.id
        vm.correct()
        XCTAssertEqual(vm.remaining, 0)
        XCTAssertFalse(UserDataController.shared!.reverseReadyToReviewCards().contains { $0.id == beforeID })

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
}

extension ReviewViewModelTests {
    @discardableResult
    func createCard(normalNextReview: Date, reverseNextReview: Date) -> String {
        let id = NSUUID().uuidString
        try! UserDataController.shared!.createCard(id: id, question: "A", answer: "B", isReviewing: true, normalSuccessCount: 1, reverseSuccessCount: 1, normalNextReviewDate: normalNextReview, reverseNextReviewDate: reverseNextReview)
        
        return id
    }
}

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
}

extension ReviewViewModelTests {
    @discardableResult
    func createCard(normalNextReview: Date, reverseNextReview: Date) -> String {
        let id = NSUUID().uuidString
        try! UserDataController.shared!.createCard(id: id, question: "A", answer: "B", isReviewing: true, normalSuccessCount: 1, reverseSuccessCount: 1, normalNextReviewDate: normalNextReview, reverseNextReviewDate: reverseNextReview)
        
        return id
    }
}

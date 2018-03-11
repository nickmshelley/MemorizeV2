//
//  StatsViewModelTests.swift
//  MemorizeTests
//
//  Created by Heather Shelley on 3/11/18.
//

import XCTest
@testable import Memorize

class StatsViewModelTests: XCTestCase {
    func testStats() {
        let reviewing = (1...5).map { _ in createCard(isReviewing: true) }
        let notReviewing = (1...10).map { _ in createCard(isReviewing: false) }
        let stats = StatsViewModel().stats(from: reviewing + notReviewing)
        
        XCTAssertEqual(stats.totalCards, 15)
        XCTAssertEqual(stats.totalReviewing, 5)
        XCTAssertEqual(stats.totalNotReviewing, 10)
    }
}

extension StatsViewModelTests {
    private func createCard(isReviewing: Bool) -> Card {
        return Card(id: "", question: "", answer: "", isReviewing: isReviewing, normalSuccessCount: 0, reverseSuccessCount: 0, normalNextReviewDate: nil, reverseNextReviewDate: nil)
    }
}

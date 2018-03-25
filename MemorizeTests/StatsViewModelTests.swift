//
//  StatsViewModelTests.swift
//  MemorizeTests
//
//  Created by Heather Shelley on 3/11/18.
//

import XCTest
@testable import Memorize

class StatsViewModelTests: XCTestCase {
    func testTotals() {
        let reviewing = (1...5).map { _ in createCard(isReviewing: true) }
        let notReviewing = (1...10).map { _ in createCard(isReviewing: false) }
        let stats = StatsViewModel().stats(from: reviewing + notReviewing)
        
        XCTAssertEqual(stats.totalCards, 15)
        XCTAssertEqual(stats.totalReviewing, 5)
        XCTAssertEqual(stats.totalNotReviewing, 10)
    }
    
    func testReadyToReview() {
        let normalReady = (1...5).map { _ in createCard(isReadyNormal: true, isReadyReverse: false) }
        let reverseReady = (1...10).map { _ in createCard(isReadyNormal: false, isReadyReverse: true) }
        let notReady = (1...5).map { _ in createCard(isReadyNormal: false, isReadyReverse: false) }
        let stats = StatsViewModel().stats(from: normalReady + reverseReady + notReady)
        
        XCTAssertEqual(stats.normalReadyToReview, 5)
        XCTAssertEqual(stats.reverseReadyToReview, 10)
    }
    
    func testAverages() {
        var normalAverage = 0.0
        var reverseAverage = 0.0
        
        let set1 = (1...3).map { _ in createCard(normalSuccessCount: 1, reverseSuccessCount: 2) }
        normalAverage += 3
        reverseAverage += 3 / 4
        
        let set2 = (1...4).map { _ in createCard(normalSuccessCount: 5, reverseSuccessCount: 3) }
        normalAverage += 4 / 25
        reverseAverage += 4 / 9
        
        let set3 = (1...10).map { _ in createCard(normalSuccessCount: 33, reverseSuccessCount: 24) }
        normalAverage += 0.1
        reverseAverage += 0.1
        
        let stats = StatsViewModel().stats(from: set1 + set2 + set3)
        
        XCTAssertEqual(stats.normalAveragePerDay, normalAverage, accuracy: 0.01)
        XCTAssertEqual(stats.reverseAveragePerDay, reverseAverage, accuracy: 0.01)
    }
    
    func testDayStats() {
        let set1 = (1...3).map { _ in createCard(normalSuccessCount: 1, reverseSuccessCount: 2, isReady: true) }
        let set2 = (1...5).map { _ in createCard(normalSuccessCount: 1, reverseSuccessCount: 2, isReady: false) }
        
        let set3 = (1...4).map { _ in createCard(normalSuccessCount: 4, reverseSuccessCount: 3, isReady: true) }
        let set4 = (1...3).map { _ in createCard(normalSuccessCount: 4, reverseSuccessCount: 3, isReady: false) }
        let set5 = (1...2).map { _ in createCard(normalSuccessCount: 3, reverseSuccessCount: 4, isReady: true)}
        let stats = StatsViewModel().stats(from: set1 + set2 + set3 + set4 + set5)
        
        let dayStats = stats.dayStats
        XCTAssertEqual(dayStats.count, 4)
        let oneDay = dayStats[0]
        let twoDay = dayStats[1]
        let threeDay = dayStats[2]
        let fourDay = dayStats[3]
        
        XCTAssertEqual(oneDay.dayDifference, 1)
        XCTAssertEqual(oneDay.normalTotal, 8)
        XCTAssertEqual(oneDay.reverseTotal, 0)
        XCTAssertEqual(oneDay.normalNeedsReview, 3)
        XCTAssertEqual(oneDay.reverseNeedsReview, 0)
        
        XCTAssertEqual(twoDay.dayDifference, 4)
        XCTAssertEqual(twoDay.normalTotal, 0)
        XCTAssertEqual(twoDay.reverseTotal, 8)
        XCTAssertEqual(twoDay.normalNeedsReview, 0)
        XCTAssertEqual(twoDay.reverseNeedsReview, 3)
        
        XCTAssertEqual(threeDay.dayDifference, 9)
        XCTAssertEqual(threeDay.normalTotal, 2)
        XCTAssertEqual(threeDay.reverseTotal, 7)
        XCTAssertEqual(threeDay.normalNeedsReview, 2)
        XCTAssertEqual(threeDay.reverseNeedsReview, 4)
        
        XCTAssertEqual(fourDay.dayDifference, 16)
        XCTAssertEqual(fourDay.normalTotal, 7)
        XCTAssertEqual(fourDay.reverseTotal, 2)
        XCTAssertEqual(fourDay.normalNeedsReview, 4)
        XCTAssertEqual(fourDay.reverseNeedsReview, 2)
    }
}

extension StatsViewModelTests {
    private func createCard(isReviewing: Bool) -> Card {
        return Card(id: "", question: "", answer: "", isReviewing: isReviewing, normalSuccessCount: 0, reverseSuccessCount: 0, normalNextReviewDate: nil, reverseNextReviewDate: nil)
    }
    
    private func createCard(isReadyNormal: Bool, isReadyReverse: Bool) -> Card {
        let normalToAdd: TimeInterval = isReadyNormal ? -20 : 20
        let reverseToAdd: TimeInterval = isReadyReverse ? -20 : 20
        
        return Card(id: "", question: "", answer: "", isReviewing: true, normalSuccessCount: 3, reverseSuccessCount: 3, normalNextReviewDate: Date().addingTimeInterval(normalToAdd), reverseNextReviewDate: Date().addingTimeInterval(reverseToAdd))
    }
    
    private func createCard(normalSuccessCount: Int, reverseSuccessCount: Int) -> Card {
        return Card(id: "", question: "", answer: "", isReviewing: true, normalSuccessCount: normalSuccessCount, reverseSuccessCount: reverseSuccessCount, normalNextReviewDate: nil, reverseNextReviewDate: nil)
    }
    
    private func createCard(normalSuccessCount: Int, reverseSuccessCount: Int, isReady: Bool) -> Card {
        let toAdd: TimeInterval = isReady ? -20 : 20
        let date = Date().addingTimeInterval(toAdd)
        return Card(id: "", question: "", answer: "", isReviewing: true, normalSuccessCount: normalSuccessCount, reverseSuccessCount: reverseSuccessCount, normalNextReviewDate: date, reverseNextReviewDate: date)
    }
}

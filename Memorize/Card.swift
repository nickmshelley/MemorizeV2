//
//  Card.swift
//  Memorize
//
//  Created by Heather Shelley on 2/23/18.
//

import Foundation

struct Card {
    let id: String
    let question: String
    let answer: String
    let isReviewing: Bool
    let normalSuccessCount: Int
    let reverseSuccessCount: Int
    let normalNextReviewDate: Date?
    let reverseNextReviewDate: Date?
}

extension Card {
    func needsNormalReview() -> Bool {
        guard let nextReview = normalNextReviewDate else { return false }
        return Date() >= nextReview
    }
    
    func needsReverseReview() -> Bool {
        guard let nextReview = reverseNextReviewDate else { return false }
        return Date() >= nextReview
    }
    
    func normalDayDifference() -> Int {
        return dayDifference(successCount: normalSuccessCount)
    }
    
    func reverseDayDifference() -> Int {
        return dayDifference(successCount: reverseSuccessCount)
    }
    
    private func dayDifference(successCount: Int) -> Int {
        return max(1, min(100, Int(pow(Double(successCount), 2))))
    }
}

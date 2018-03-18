//
//  StatsViewModel.swift
//  Memorize
//
//  Created by Heather Shelley on 3/11/18.
//

import Foundation

struct Stats {
    let totalCards: Int
    let totalReviewing: Int
    let totalNotReviewing: Int
    let normalReadyToReview: Int
    let reverseReadyToReview: Int
    let normalAveragePerDay: Double
    let reverseAveragePerDay: Double
    let normalDayStats: [StatsInfo]
    let reverseDayStats: [StatsInfo]
}

struct StatsInfo {
    let dayDifference: Int
    let total: Int
    let needsReview: Int
}

struct StatsViewModel {
    func stats(from cards: [Card]) -> Stats {
        let total = cards.count
        let reviewing = cards.filter { $0.isReviewing }.count
        let notReviewing = total - reviewing
        let normalReadyToReview = cards.filter { $0.needsNormalReview() }.count
        let reverseReadyToReview = cards.filter { $0.needsReverseReview() }.count
        
        return Stats(totalCards: total,
                     totalReviewing: reviewing,
                     totalNotReviewing: notReviewing,
                     normalReadyToReview: normalReadyToReview,
                     reverseReadyToReview: reverseReadyToReview,
                     normalAveragePerDay: 0,
                     reverseAveragePerDay: 0,
                     normalDayStats: [],
                     reverseDayStats: [])
    }
}

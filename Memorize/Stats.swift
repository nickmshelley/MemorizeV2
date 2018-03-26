//
//  Stats.swift
//  Memorize
//
//  Created by Heather Shelley on 3/25/18.
//

import Foundation

struct Stats {
    let totalCards: Int
    let totalReviewing: Int
    let normalReadyToReview: Int
    let reverseReadyToReview: Int
    let normalAveragePerDay: Double
    let reverseAveragePerDay: Double
    let dayStats: [StatsInfo]
}

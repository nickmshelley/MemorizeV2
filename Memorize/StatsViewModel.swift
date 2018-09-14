//
//  StatsViewModel.swift
//  Memorize
//
//  Created by Heather Shelley on 3/11/18.
//

import Foundation
import Swiftification

private enum ReviewType {
    case normal
    case reverse
}

private struct MyStatsInfo {
    let dayDifference: Int
    let total: Int
    let needsReview: Int
    let type: ReviewType
}

struct StatsViewModel {
    func stats(from cards: [Card]) -> Stats {
        let total = cards.count
        let reviewing = cards.filter { $0.isReviewing }.count
        let normalReadyToReview = cards.filter { $0.needsNormalReview() }.count
        let reverseReadyToReview = cards.filter { $0.needsReverseReview() }.count
        
        let normalStatsInfos: [MyStatsInfo] = cards.sectioned { $0.normalSuccessCount }
            .map {
                let items = $0.items
                let total = items.count
                let dayDifference = items[0].normalDayDifference()
                let needsReview = items.filter { $0.needsNormalReview() }.count
                return MyStatsInfo(dayDifference: dayDifference, total: total, needsReview: needsReview, type: .normal)
        }
        let normalAveragePerDay = normalStatsInfos.reduce(0) { $0 + Double($1.total) / Double($1.dayDifference) }
        
        let reverseStatsInfos: [MyStatsInfo] = cards.sectioned { $0.reverseSuccessCount }
            .map {
                let items = $0.items
                let total = items.count
                let dayDifference = items[0].reverseDayDifference()
                let needsReview = items.filter { $0.needsReverseReview() }.count
                return MyStatsInfo(dayDifference: dayDifference, total: total, needsReview: needsReview, type: .reverse)
        }
        let reverseAveragePerDay = reverseStatsInfos.reduce(0) { $0 + Double($1.total) / Double($1.dayDifference) }
        
        let statsInfos: [StatsInfo] = (normalStatsInfos + reverseStatsInfos)
            .sorted { $0.dayDifference < $1.dayDifference }
            .sectioned { $0.dayDifference }
            .map {
                let dayDifference = $0.header
                var normalTotal = 0
                var reverseTotal = 0
                var normalNeedsReview = 0
                var reverseNeedsReview = 0
                
                for myStats in $0.items {
                    switch myStats.type {
                    case .normal:
                        normalTotal += myStats.total
                        normalNeedsReview += myStats.needsReview
                    case .reverse:
                        reverseTotal += myStats.total
                        reverseNeedsReview += myStats.needsReview
                    }
                }
                
                return StatsInfo(dayDifference: dayDifference, normalTotal: normalTotal, reverseTotal: reverseTotal, normalNeedsReview: normalNeedsReview, reverseNeedsReview: reverseNeedsReview)
        }
        
        return Stats(totalCards: total,
                     totalReviewing: reviewing,
                     normalReadyToReview: normalReadyToReview,
                     reverseReadyToReview: reverseReadyToReview,
                     normalAveragePerDay: normalAveragePerDay,
                     reverseAveragePerDay: reverseAveragePerDay,
                     dayStats: statsInfos)
    }
}

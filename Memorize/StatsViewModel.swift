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
}

struct StatsViewModel {
    func stats(from cards: [Card]) -> Stats {
        let total = cards.count
        let reviewing = cards.filter { $0.isReviewing }.count
        let notReviewing = total - reviewing
        
        return Stats(totalCards: total, totalReviewing: reviewing, totalNotReviewing: notReviewing)
    }
}

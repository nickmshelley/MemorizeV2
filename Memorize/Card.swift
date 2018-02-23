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

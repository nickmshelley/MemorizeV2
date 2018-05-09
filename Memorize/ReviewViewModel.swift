//
//  ReviewViewModel.swift
//  Memorize
//
//  Created by Nick Shelley on 5/5/18.
//

import Foundation

class ReviewViewModel {
    var question: String? {
        return currentCard?.question
    }
    var answer: String? {
        return currentCard?.answer
    }
    var isNormal = true
    var remaining = 0
    private var cards: [Card] = []
    private var currentCard: Card?
    private var undoStack: [UndoObject] = []
    private var previousCard: Card?
    private var normalReviewed: Int {
        get {
            return UserDefaults.standard.integer(forKey: "normalReviewed")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "normalReviewed")
        }
    }
    private var reverseReviewed: Int {
        get {
            return UserDefaults.standard.integer(forKey: "reverseReviewed")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "reverseReviewed")
        }
    }
    
    init() {
        updateCurrentCard()
    }
}

extension ReviewViewModel {
    private func refreshCards() {
        cards = UserDataController.shared?.normalReadyToReviewCards() ?? []
        if cards.isEmpty {
            cards = UserDataController.shared?.reverseReadyToReviewCards() ?? []
            isNormal = cards.isEmpty
        }
        remaining = cards.count
    }
    
    private func updateCurrentCard() {
        if cards.isEmpty {
            refreshCards()
            if cards.isEmpty {
                currentCard = nil
                previousCard = nil
                return
            }
        }
        
        previousCard = currentCard
        currentCard = cards.random()
    }
}

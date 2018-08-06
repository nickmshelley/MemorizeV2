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
    var currentCard: Card?
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
    func correct() {
        guard let currentCard = currentCard else { return }
        
        if isNormal {
            let nextDate = Calendar.current.date(byAdding: .day, value: currentCard.normalDayDifference(), to: DateHelpers.threeAM())!
            try! UserDataController.shared?.updateNormalReview(ofCardWithID: currentCard.id, nextReview: nextDate, successCount: currentCard.normalSuccessCount + 1)
        } else {
            let nextDate = Calendar.current.date(byAdding: .day, value: currentCard.reverseDayDifference(), to: DateHelpers.threeAM())!
            try! UserDataController.shared?.updateReverseReview(ofCardWithID: currentCard.id, nextReview: nextDate, successCount: currentCard.reverseSuccessCount + 1)
        }
        
        cards.remove(at: cards.index(of: currentCard)!)
        remaining -= 1
        updateCurrentCard()
    }
    
    func missed() {
        guard let currentCard = currentCard else { return }
        
        if isNormal {
            try! UserDataController.shared?.updateNormalReviewMissed(ofCardWithID: currentCard.id)
        } else {
            try! UserDataController.shared?.updateReverseReviewMissed(ofCardWithID: currentCard.id)
        }
        
        updateCurrentCard()
    }
}

private extension ReviewViewModel {
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
        
        if cards.count > 1 {
            while currentCard == previousCard {
                currentCard = cards.random()
            }
        }
    }
}

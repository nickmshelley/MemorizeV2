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
    
    init() {
        updateCurrentCard()
    }
}

extension ReviewViewModel {
    func refresh() {
        guard SettingsController.lastRefresh < DateHelpers.threeAM() else { return }
        
        SettingsController.normalReviewedToday = 0
        SettingsController.reverseReviewedToday = 0
        SettingsController.lastRefresh = Date()
        
        refreshCards()
        updateCurrentCard()
    }
    
    func correct() {
        guard let currentCard = currentCard else { return }
        
        undoStack.append(UndoObject(card: currentCard, correct: true, isNormal: isNormal))
        
        if isNormal {
            let nextDate = Calendar.current.date(byAdding: .day, value: currentCard.dayDifference(successCount: currentCard.normalSuccessCount + 1), to: DateHelpers.threeAM())!
            try! UserDataController.shared?.updateNormalReview(ofCardWithID: currentCard.id, nextReview: nextDate, successCount: currentCard.normalSuccessCount + 1)
            SettingsController.normalReviewedToday += 1
        } else {
            let nextDate = Calendar.current.date(byAdding: .day, value: currentCard.dayDifference(successCount: currentCard.reverseSuccessCount + 1), to: DateHelpers.threeAM())!
            try! UserDataController.shared?.updateReverseReview(ofCardWithID: currentCard.id, nextReview: nextDate, successCount: currentCard.reverseSuccessCount + 1)
            SettingsController.reverseReviewedToday += 1
        }
        
        cards.remove(at: cards.firstIndex(of: currentCard)!)
        remaining -= 1
        updateCurrentCard()
    }
    
    func missed() {
        guard let currentCard = currentCard else { return }
        
        undoStack.append(UndoObject(card: currentCard, correct: false, isNormal: isNormal))
        
        let updatedCard: Card
        if isNormal {
            updatedCard = try! UserDataController.shared!.updateNormalReviewMissed(ofCardWithID: currentCard.id)
        } else {
            updatedCard = try! UserDataController.shared!.updateReverseReviewMissed(ofCardWithID: currentCard.id)
        }
        
        cards.remove(at: cards.firstIndex(of: currentCard)!)
        cards.append(updatedCard)
        updateCurrentCard()
    }
    
    func undo() {
        guard let undoObject = undoStack.popLast() else { return }
        
        let card = undoObject.card
        currentCard = card
        
        if undoObject.isNormal {
            let updatedCard = try! UserDataController.shared!.updateNormalReview(ofCardWithID: card.id, nextReview: card.normalNextReviewDate!, successCount: card.normalSuccessCount)
            if undoObject.correct {
                SettingsController.normalReviewedToday -= 1
                if isNormal {
                    cards.append(card)
                } else {
                    isNormal = true
                    cards = [card]
                }
            } else {
                cards.remove(at: cards.firstIndex(where: { $0.id == card.id })!)
                cards.append(updatedCard)
            }
        } else {
            isNormal = false
            let updatedCard = try! UserDataController.shared!.updateReverseReview(ofCardWithID: card.id, nextReview: card.reverseNextReviewDate!, successCount: card.reverseSuccessCount)
            if undoObject.correct {
                SettingsController.reverseReviewedToday -= 1
                cards.append(card)
            } else {
                cards.remove(at: cards.firstIndex(where: { $0.id == card.id })!)
                cards.append(updatedCard)
            }
        }
        
        remaining = cards.count
    }
    
    func addMoreNormal() {
        cards = UserDataController.shared?.todaysNormalReviewCards(perDay: 10, force: true) ?? []
        isNormal = true
        remaining = cards.count
        
        updateCurrentCard()
    }
    
    func addMoreReverse() {
        cards = UserDataController.shared?.todaysReverseReviewCards(perDay: 10, force: true) ?? []
        isNormal = false
        remaining = cards.count
        
        updateCurrentCard()
    }
}

private extension ReviewViewModel {
    private func refreshCards() {
        cards = UserDataController.shared?.todaysNormalReviewCards() ?? []
        if cards.isEmpty {
            cards = UserDataController.shared?.todaysReverseReviewCards() ?? []
            isNormal = cards.isEmpty
        } else {
            isNormal = true
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
            while currentCard?.id == previousCard?.id {
                currentCard = cards.random()
            }
        }
    }
}

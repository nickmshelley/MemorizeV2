//
//  SettingsController.swift
//  Memorize
//
//  Created by Heather Shelley on 4/3/18.
//

import Foundation

struct SettingsController {
    private static let cardsToReviewPerDayKey = "cardsToReviewPerDay"
    
    static var cardsToReviewPerDay: Int {
        get {
            let perDay = UserDefaults.standard.integer(forKey: cardsToReviewPerDayKey)
            return perDay > 0 ? perDay : 15
        }
        set {
            UserDefaults.standard.set(newValue, forKey: cardsToReviewPerDayKey)
        }
    }
    
    static var normalReviewedToday: Int {
        get {
            return UserDefaults.standard.integer(forKey: "normalReviewedToday")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "normalReviewedToday")
        }
    }
    
    static var reverseReviewedToday: Int {
        get {
            return UserDefaults.standard.integer(forKey: "reverseReviewedToday")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "reverseReviewedToday")
        }
    }
}

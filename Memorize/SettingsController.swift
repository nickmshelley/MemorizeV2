//
//  SettingsController.swift
//  Memorize
//
//  Created by Heather Shelley on 4/3/18.
//

import Foundation

struct SettingsController {
    static var cardsToReviewPerDay: Int {
        get {
            let perDay = UserDefaults.standard.integer(forKey: "cardsToReviewPerDay")
            return perDay > 0 ? perDay : 15
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "cardsToReviewPerDay")
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
    
    static var lastRefresh: Date {
        get {
            return UserDefaults.standard.object(forKey: "lastRefresh") as? Date ?? .distantPast
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastRefresh")
        }
    }
}

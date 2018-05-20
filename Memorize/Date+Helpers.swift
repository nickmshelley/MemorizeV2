//
//  Date+Helpers.swift
//  Memorize
//
//  Created by Heather Shelley on 5/20/18.
//

import Foundation

extension Date {
    static func threeAMToday() -> Date {
        let date = Date()
        let calendar = Calendar.autoupdatingCurrent
        guard let hour = calendar.dateComponents([.hour], from: date).hour else { return date }
        let secondsToSubtract = hour < 3 ? 60 * 60 * 24 : 0
        return calendar.date(from: calendar.dateComponents([.year, .month, .day], from: date))?.addingTimeInterval((TimeInterval(60 * 60 * 3 - secondsToSubtract))) ?? date
    }
}

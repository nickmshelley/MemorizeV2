//
//  UserDataController.swift
//  Memorize
//
//  Created by Heather Shelley on 2/23/18.
//

import Foundation
import SQLite
import Swiftification

class UserDataController {
    static var shared = UserDataController(path: UserDataController.databasePath())
    
    fileprivate let databaseVersionKey = "databaseVersion"
    
    let db: Connection
    
    init?(path: String?) {
        do {
            if let path = path {
                db = try Connection(path, readonly: false)
            } else {
                db = try Connection()
            }
            db.busyTimeout = 5
            
            try db.execute("PRAGMA synchronous = OFF")
            try db.execute("PRAGMA temp_store = MEMORY")
            
            try upgradeDatabaseToLatestVersion()
        } catch {
            print("Failed to create UserDataController:", error)
            return nil
        }
    }
    
    func inTransaction(_ closure: @escaping () throws -> Void) throws {
        let inTransactionKey = "txn:\(Unmanaged.passUnretained(self).toOpaque())"
        if Thread.current.threadDictionary[inTransactionKey] != nil {
            try closure()
        } else {
            Thread.current.threadDictionary[inTransactionKey] = true
            defer { Thread.current.threadDictionary.removeObject(forKey: inTransactionKey) }
            try db.transaction {
                try closure()
            }
        }
    }

    class func databasePath() -> String? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.appendingPathComponent("UserData.sqlite").path
    }
    
    fileprivate func databaseVersion() -> Int {
        return valueForMetadataKey(databaseVersionKey).flatMap { Int($0) } ?? 0
    }
    
    fileprivate func setDatabaseVersion(_ version: Int) throws {
        try setValue(String(version), forMetadataKey: databaseVersionKey)
    }
    
    fileprivate func upgradeDatabaseToLatestVersion() throws {
        if databaseVersion() < 1 {
            try db.transaction {
                try self.db.run(MetadataTable.createTable())
                try self.db.run(CardTable.createTable())
                
                try self.setDatabaseVersion(1)
                
                //importInitial()
            }
        }
    }
    
}

// MARK: - Metadata
extension UserDataController {
    fileprivate class MetadataTable {
        static let table = Table("metadata")
        
        static let key = Expression<String>("key")
        static let value = Expression<String>("value")
        
        static func createTable() -> String {
            return MetadataTable.table.create { table in
                table.column(MetadataTable.key, primaryKey: true)
                table.column(MetadataTable.value)
            }
        }
        
    }
    
    fileprivate func metadataTableExists() -> Bool {
        do {
            guard let exists = try db.scalar("SELECT EXISTS (SELECT * FROM sqlite_master WHERE type = 'table' AND name = ?)", "metadata") as? Int64 else { return false }
            
            return exists != 0
        } catch {
            print(error)
            return false
        }
    }
    
    func valueForMetadataKey(_ key: String) -> String? {
        do {
            guard metadataTableExists() else { return nil }
            
            return try db.pluck(MetadataTable.table.filter(MetadataTable.key == key)).map { $0[MetadataTable.value] }
        } catch {
            print(error)
            return nil
        }
    }
    
    func setValue(_ value: String, forMetadataKey key: String) throws {
        do {
            try db.run(MetadataTable.table.insert(or: .replace,
                                                  MetadataTable.key <- key,
                                                  MetadataTable.value <- value
            ))
        }
    }
}

extension UserDataController {
    private class CardTable {
        static let table = Table("card")
        
        static let id = Expression<String>("card_id")
        static let question = Expression<String>("question")
        static let answer = Expression<String>("answer")
        static let isReviewing = Expression<Bool>("is_reviewing")
        static let normalSuccessCount = Expression<Int>("normal_success_count")
        static let reverseSuccessCount = Expression<Int>("reverse_success_count")
        static let normalNextReviewDate = Expression<Date?>("normal_next_review_date")
        static let reverseNextReviewDate = Expression<Date?>("reverse_next_review_date")
        
        static func fromRow(_ row: Row) throws -> Card {
            return Card(
                id: try row.get(id),
                question: try row.get(question),
                answer: try row.get(answer),
                isReviewing: try row.get(isReviewing),
                normalSuccessCount: try row.get(normalSuccessCount),
                reverseSuccessCount: try row.get(reverseSuccessCount),
                normalNextReviewDate: try row.get(normalNextReviewDate),
                reverseNextReviewDate: try row.get(reverseNextReviewDate)
            )
        }
        
        static func createTable() -> String {
            return CardTable.table.create { table in
                table.column(CardTable.id, primaryKey: true)
                table.column(CardTable.question)
                table.column(CardTable.answer)
                table.column(CardTable.isReviewing)
                table.column(CardTable.normalSuccessCount)
                table.column(CardTable.reverseSuccessCount)
                table.column(CardTable.normalNextReviewDate)
                table.column(CardTable.reverseNextReviewDate)
            }
        }
    }
    
    func card(withID id: String) throws -> Card? {
        return try db.pluck(CardTable.table.filter(CardTable.id == id)).map { try CardTable.fromRow($0) }
    }
    
    func allCards() -> [Card] {
        do {
            return try db.prepareRowIterator(CardTable.table.order(CardTable.question)).map { try CardTable.fromRow($0) }
        } catch {
            print("Failed to retrieve cards:", error)
            return []
        }
    }
    
    func reviewingCards() -> [Card] {
        do {
            return try db.prepareRowIterator(CardTable.table.filter(CardTable.isReviewing == true).order(CardTable.question)).map { try CardTable.fromRow($0) }
        } catch {
            print("Failed to retrieve cards:", error)
            return []
        }
    }
    
    func normalReadyToReviewCards() -> [Card] {
        do {
            let now = Date()
            return try db.prepareRowIterator(CardTable.table.filter(CardTable.isReviewing == true && CardTable.normalNextReviewDate < now)).map { try CardTable.fromRow($0) }
        } catch {
            print("Failed to retrieve ready cards:", error)
            return []
        }
    }
    
    func reverseReadyToReviewCards() -> [Card] {
        do {
            let now = Date()
            return try db.prepareRowIterator(CardTable.table.filter(CardTable.isReviewing == true && CardTable.reverseNextReviewDate < now)).map { try CardTable.fromRow($0) }
        } catch {
            print("Failed to retrieve ready cards:", error)
            return []
        }
    }
    
    func todaysNormalReviewCards(perDay: Int = SettingsController.cardsToReviewPerDay) -> [Card] {
        let allReady = normalReadyToReviewCards()
        guard allReady.count > perDay else { return allReady }
        let sorted = allReady.sorted { card1, card2 in
            if card1.normalSuccessCount == card2.normalSuccessCount, let nextReview1 = card1.normalNextReviewDate, let nextReview2 = card2.normalNextReviewDate {
                if nextReview1 == nextReview2 {
                    return card1.id < card2.id
                } else {
                    return nextReview1 < nextReview2
                }
            } else {
                return card1.normalSuccessCount < card2.normalSuccessCount
            }
        }
        let partitioned = sorted.partitioned { $0.normalSuccessCount }
        
        var result = [Card]()
        var currentIndex = 0
        while result.count < perDay {
            for day in partitioned {
                if result.count < perDay, let card = day[safe: currentIndex] {
                    result.append(card)
                }
            }
            currentIndex += 1
        }
        
        return result
    }
    
    func todaysReverseReviewCards(perDay: Int = SettingsController.cardsToReviewPerDay) -> [Card] {
        let allReady = reverseReadyToReviewCards()
        guard allReady.count > perDay else { return allReady }
        let sorted = allReady.sorted { card1, card2 in
            if card1.reverseSuccessCount == card2.reverseSuccessCount, let nextReview1 = card1.reverseNextReviewDate, let nextReview2 = card2.reverseNextReviewDate {
                if nextReview1 == nextReview2 {
                    return card1.id < card2.id
                } else {
                    return nextReview1 < nextReview2
                }
            } else {
                return card1.reverseSuccessCount < card2.reverseSuccessCount
            }
        }
        let partitioned = sorted.partitioned { $0.reverseSuccessCount }
        
        var result = [Card]()
        var currentIndex = 0
        while result.count < perDay {
            for day in partitioned {
                if result.count < perDay, let card = day[safe: currentIndex] {
                    result.append(card)
                }
            }
            currentIndex += 1
        }
        
        return result
    }
    
    @discardableResult
    func updateNormalReviewMissed(ofCardWithID id: String) throws -> Card {
        try db.run(CardTable.table.filter(CardTable.id == id).update(
            CardTable.normalSuccessCount <- 0
        ))
        
        return try card(withID: id)!
    }
    
    @discardableResult
    func updateReverseReviewMissed(ofCardWithID id: String) throws -> Card {
        try db.run(CardTable.table.filter(CardTable.id == id).update(
            CardTable.reverseSuccessCount <- 0
        ))
        
        return try card(withID: id)!
    }
    
    @discardableResult
    func updateNormalReview(ofCardWithID id: String, nextReview: Date, successCount: Int) throws -> Card {
        try db.run(CardTable.table.filter(CardTable.id == id).update(
            CardTable.normalNextReviewDate <- nextReview,
            CardTable.normalSuccessCount <- successCount
        ))
        
        return try card(withID: id)!
    }
    
    @discardableResult
    func updateReverseReview(ofCardWithID id: String, nextReview: Date, successCount: Int) throws -> Card {
        try db.run(CardTable.table.filter(CardTable.id == id).update(
            CardTable.reverseNextReviewDate <- nextReview,
            CardTable.reverseSuccessCount <- successCount
        ))
        
        return try card(withID: id)!
    }
    
    @discardableResult
    func createCard(id: String = NSUUID().uuidString, question: String, answer: String, isReviewing: Bool = false, normalSuccessCount: Int = 0, reverseSuccessCount: Int = 0, normalNextReviewDate: Date? = nil, reverseNextReviewDate: Date? = nil) throws -> String {
        try db.run(CardTable.table.insert(
            CardTable.id <- id,
            CardTable.question <- question,
            CardTable.answer <- answer,
            CardTable.isReviewing <- isReviewing,
            CardTable.normalSuccessCount <- normalSuccessCount,
            CardTable.reverseSuccessCount <- reverseSuccessCount,
            CardTable.normalNextReviewDate <- normalNextReviewDate,
            CardTable.reverseNextReviewDate <- reverseNextReviewDate
        ))
        
        return id
    }
}

extension UserDataController {
    private func importInitial() {
        let jsonData = try! Data(contentsOf: Bundle.main.url(forResource: "cards", withExtension: "json")!)
        let cards = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [[String: Any]]
        var tempSet = Set<String>()
        var uniqueCards = [(question: String, answer: String)]()
        for jsonCard in cards {
            let question = jsonCard["question"] as! String
            let answer = jsonCard["answer"] as! String
            let cleanedUpQuestion = question.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\u{00a0}", with: " ")
            if !tempSet.contains(cleanedUpQuestion) {
                tempSet.insert(cleanedUpQuestion)
                uniqueCards.append((question: cleanedUpQuestion, answer: processedAnswer(raw: answer)))
            }
        }
        
        for (question, answer) in uniqueCards {
            let date = Date()
            try! createCard(question: question, answer: answer, isReviewing: true, normalSuccessCount: 10, reverseSuccessCount: 10, normalNextReviewDate: date, reverseNextReviewDate: date)
        }
    }
    
    private func processedAnswer(raw: String) -> String {
        let components = raw.components(separatedBy: .newlines).filter { !$0.isEmpty }
        return components.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.joined(separator: "\n\n")
    }
}

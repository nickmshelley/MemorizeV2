//
//  UserDataController.swift
//  Memorize
//
//  Created by Heather Shelley on 2/23/18.
//

import Foundation
import SQLite

class UserDataController {
    static let shared = UserDataController(path: UserDataController.databasePath())
    
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
    
    func allCards() throws -> [Card] {
        return try db.prepareRowIterator(CardTable.table.order(CardTable.question)).map { try CardTable.fromRow($0) }
    }
    
    func createCard(question: String, answer: String) throws {
        let uuid = NSUUID().uuidString
        try db.run(CardTable.table.insert(
            CardTable.id <- uuid,
            CardTable.question <- question,
            CardTable.answer <- answer,
            CardTable.isReviewing <- false,
            CardTable.normalSuccessCount <- 0,
            CardTable.reverseSuccessCount <- 0,
            CardTable.normalNextReviewDate <- nil,
            CardTable.reverseNextReviewDate <- nil
        ))
    }
}

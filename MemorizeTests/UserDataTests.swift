//
//  MemorizeTests.swift
//  MemorizeTests
//
//  Created by Nick Shelley on 1/12/18.
//

import XCTest
@testable import Memorize

class UserDataTests: XCTestCase {
    func testCards() {
        let db = UserDataController(path: nil)!
        
        try! db.createCard(question: "C", answer: "D")
        try! db.createCard(question: "A", answer: "B")
        
        let cards = try! db.allCards()
        XCTAssertEqual(cards.count, 2)
        XCTAssertEqual(cards[0].question, "A")
        XCTAssertEqual(cards[0].answer, "B")
        XCTAssertEqual(cards[1].question, "C")
        XCTAssertEqual(cards[1].answer, "D")
    }
}

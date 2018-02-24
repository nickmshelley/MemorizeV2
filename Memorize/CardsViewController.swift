//
//  CardsViewController.swift
//  Memorize
//
//  Created by Nick Shelley on 1/12/18.
//

import UIKit

class CardsViewController: UITableViewController {
    private var cards: [Card] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Cards"
        do {
            cards = try UserDataController.shared?.allCards() ?? []
        } catch {
            print("Couldn't load cards.")
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

extension CardsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let card = cards[indexPath.row]
        cell.textLabel?.text = card.question
        return cell
    }
}

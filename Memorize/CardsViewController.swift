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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        cards = UserDataController.shared?.allCards() ?? []
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let card = cards[indexPath.row]
        navigationController?.pushViewController(CardViewerViewController(card: card), animated: true)
    }
}

extension CardsViewController {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let card = cards[indexPath.row]
            try! UserDataController.shared?.deleteCard(withID: card.id)
            cards.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

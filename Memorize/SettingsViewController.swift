//
//  SettingsViewController.swift
//  Memorize
//
//  Created by Nick Shelley on 1/12/18.
//

import UIKit

class SettingsViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        tableView.register(CardsPerDayCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CardsPerDayCell
        cell.configure(cardsPerDay: SettingsController.cardsToReviewPerDay, buttonHandler: { [weak self] difference in
            let current = SettingsController.cardsToReviewPerDay
            switch difference {
            case .addOne:
                SettingsController.cardsToReviewPerDay = current + 1
            case .addFive:
                SettingsController.cardsToReviewPerDay = current + 5
            case .minusOne:
                SettingsController.cardsToReviewPerDay = current - 1
            case .minusFive:
                SettingsController.cardsToReviewPerDay = current - 5
            }
            
            self?.tableView.reloadData()
        })
        return cell
    }
}

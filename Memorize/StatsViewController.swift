//
//  StatsViewController.swift
//  Memorize
//
//  Created by Nick Shelley on 1/12/18.
//

import UIKit

private struct Section {
    let title: String
    let rows: [Row]
}

private struct Row {
    let topText: String
    let middleText: String
    let bottomText: String
}

class StatsViewController: UITableViewController {
    private var sections: [Section] = []
    private let viewModel = StatsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Stats"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.allowsSelection = false
        
        do {
            let cards = try UserDataController.shared?.allCards() ?? []
            let stats = viewModel.stats(from: cards)
            let row = Row(topText: "Total Cards: \(stats.totalCards)",
                middleText: "Reviewing: \(stats.totalReviewing)",
                bottomText: "Not Reviewing: \(stats.totalNotReviewing)")
            sections = [Section(title: "Totals", rows: [row])]
        } catch {
            print("Couldn't load cards.")
        }
    }
}

extension StatsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let row = sections[indexPath.section].rows[indexPath.row]
        cell.textLabel?.text = [row.topText, row.middleText, row.bottomText].joined(separator: " /// ")
        return cell
    }
}

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
    let middleText: String?
    let bottomText: String?
}

class StatsViewController: UITableViewController {
    private var sections: [Section] = []
    private let viewModel = StatsViewModel()
    private lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Stats"
        tableView.register(StatCell.self, forCellReuseIdentifier: "Cell")
        tableView.allowsSelection = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        let cards = UserDataController.shared?.allCards() ?? []
        let stats = viewModel.stats(from: cards)
        let totalRow = Row(topText: "Total Cards: \(stats.totalCards)", middleText: nil, bottomText: nil)
        let normalAverageString = formatter.string(from: NSNumber(floatLiteral: stats.normalAveragePerDay))
        let reverseAverageString = formatter.string(from: NSNumber(floatLiteral: stats.reverseAveragePerDay))
        let reviewingRow = Row(topText: "Reviewing: \(stats.totalReviewing)",
            middleText: "Normal Ready: \(stats.normalReadyToReview)",
            bottomText: "Reverse Ready: \(stats.reverseReadyToReview)")
        let averageRow = Row(topText: "Average Per Day:",
            middleText: "Normal: " + normalAverageString!,
            bottomText: "Reverse: " + reverseAverageString!)
        let totalsSection = Section(title: "Totals", rows: [totalRow, reviewingRow, averageRow])
        
        let dailyRows = stats.dayStats.map { statsInfo in
            Row(topText: "Day Difference: \(statsInfo.dayDifference)",
                middleText: "Normal: \(statsInfo.normalNeedsReview) of \(statsInfo.normalTotal)",
                bottomText: "Reverse: \(statsInfo.reverseNeedsReview) of \(statsInfo.reverseTotal)")
        }
        let daysSection = Section(title: "Need Review", rows: dailyRows)
        
        sections = [totalsSection, daysSection]
        
        tableView.reloadData()
    }
}

extension StatsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! StatCell
        let row = sections[indexPath.section].rows[indexPath.row]
        cell.configure(topText: row.topText, middleText: row.middleText, bottomText: row.bottomText)
        return cell
    }
}

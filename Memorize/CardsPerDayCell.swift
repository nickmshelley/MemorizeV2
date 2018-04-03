//
//  CardsPerDayCell.swift
//  Memorize
//
//  Created by Heather Shelley on 4/3/18.
//

import UIKit
import Anchorage

enum Difference {
    case addOne
    case addFive
    case minusOne
    case minusFive
}

class CardsPerDayCell: UITableViewCell {
    private let leftLabel = UILabel(frame: .zero)
    private let perDayLabel = UILabel(frame: .zero)
    private let minusButton = UIButton(type: .system)
    private let minusFiveButton = UIButton(type: .system)
    private let plusButton = UIButton(type: .system)
    private let plusFiveButton = UIButton(type: .system)
    
    private var callBack: (_ difference: Difference) -> Void = { _ in }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CardsPerDayCell {
    private func configureViews() {
        contentView.addSubview(leftLabel)
        let stackView = UIStackView(arrangedSubviews: [minusFiveButton, minusButton, perDayLabel, plusButton, plusFiveButton], axis: .horizontal, spacing: 0)
        contentView.addSubview(stackView)
        
        leftLabel.text = "Review per day:"
        minusButton.setTitle("-", for: .normal)
        minusFiveButton.setTitle("-5", for: .normal)
        plusButton.setTitle("+", for: .normal)
        plusFiveButton.setTitle("+5", for: .normal)
        
        minusButton.addTarget(self, action: #selector(minusButtonTapped), for: .touchUpInside)
        minusFiveButton.addTarget(self, action: #selector(minusFiveButtonTapped), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        plusFiveButton.addTarget(self, action: #selector(plusFiveButtonTapped), for: .touchUpInside)
        
        leftLabel.verticalAnchors == contentView.verticalAnchors + 16
        leftLabel.leadingAnchor == contentView.leadingAnchor + 16
        stackView.verticalAnchors == contentView.verticalAnchors + 16
        stackView.trailingAnchor == contentView.trailingAnchor - 16
    }
    
    func configure(cardsPerDay: Int, buttonHandler: @escaping (_ difference: Difference) -> Void) {
        perDayLabel.text = "  \(cardsPerDay)  "
        self.callBack = buttonHandler
    }
    
    @objc func minusButtonTapped() {
        callBack(.minusOne)
    }
    
    @objc func minusFiveButtonTapped() {
        callBack(.minusFive)
    }
    
    @objc func plusButtonTapped() {
        callBack(.addOne)
    }
    
    @objc func plusFiveButtonTapped() {
        callBack(.addFive)
    }
}

//
//  StatCell.swift
//  Memorize
//
//  Created by Heather Shelley on 3/17/18.
//

import UIKit
import Anchorage

class StatCell: UITableViewCell {
    private let topLabel = UILabel(frame: .zero)
    private let middleLabel = UILabel(frame: .zero)
    private let bottomLabel = UILabel(frame: .zero)
    private let middleContainer = UIView(frame: .zero)
    private let bottomContainer = UIView(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StatCell {
    private func configureViews() {
        middleContainer.addSubview(middleLabel)
        bottomContainer.addSubview(bottomLabel)
        let stackView = UIStackView(arrangedSubviews: [topLabel, middleContainer, bottomContainer], spacing: 8)
        contentView.addSubview(stackView)
        
        [topLabel, middleLabel, bottomLabel].forEach { $0.font = .systemFont(ofSize: 22) }
        
        stackView.edgeAnchors == contentView.edgeAnchors + 16
        
        middleLabel.leadingAnchor == middleContainer.leadingAnchor + 24
        middleLabel.trailingAnchor == middleContainer.trailingAnchor
        middleLabel.verticalAnchors == middleContainer.verticalAnchors
        
        bottomLabel.leadingAnchor == bottomContainer.leadingAnchor + 24
        bottomLabel.trailingAnchor == bottomContainer.trailingAnchor
        bottomLabel.verticalAnchors == bottomContainer.verticalAnchors
    }
    
    func configure(topText: String, middleText: String?, bottomText: String?) {
        topLabel.text = topText
        middleLabel.text = middleText
        bottomLabel.text = bottomText
        
        middleContainer.isHidden = middleText == nil
        bottomContainer.isHidden = bottomText ==  nil
    }
}

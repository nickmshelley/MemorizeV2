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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StatCell {
    private func configureViews() {
        [topLabel, middleLabel, bottomLabel].forEach {
            self.contentView.addSubview($0)
            $0.font = .systemFont(ofSize: 22)
        }
        
        let margin: Double = 16
        topLabel.horizontalAnchors == contentView.horizontalAnchors + margin
        topLabel.topAnchor == contentView.topAnchor + margin
        middleLabel.leadingAnchor == contentView.leadingAnchor + margin * 2.5
        middleLabel.trailingAnchor == contentView.trailingAnchor + margin
        middleLabel.topAnchor == topLabel.bottomAnchor + margin / 2
        bottomLabel.horizontalAnchors == middleLabel.horizontalAnchors
        bottomLabel.topAnchor == middleLabel.bottomAnchor + margin / 2
        bottomLabel.bottomAnchor == contentView.bottomAnchor - margin
    }
    
    func configure(topText: String, middleText: String, bottomText: String) {
        topLabel.text = topText
        middleLabel.text = middleText
        bottomLabel.text = bottomText
    }
}

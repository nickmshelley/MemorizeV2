//
//  UIStackView+Helpers.swift
//  Memorize
//
//  Created by Heather Shelley on 2/25/18.
//

import UIKit

extension UIStackView {
    convenience init(arrangedSubviews: [UIView], axis: UILayoutConstraintAxis = .vertical, alignment: UIStackViewAlignment = .fill, distribution: UIStackViewDistribution = .fill, spacing: CGFloat = 0) {
        self.init(arrangedSubviews: arrangedSubviews)
        self.axis = axis
        self.alignment = alignment
        self.distribution = distribution
        self.spacing = 0
    }
}

//
//  FlippableTextView.swift
//  Memorize
//
//  Created by Heather Shelley on 2/25/18.
//

import UIKit
import Anchorage

class VerticallyCenteredScrollView: UIScrollView {
    override var contentSize: CGSize {
        didSet {
            var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2.0
            topCorrection = max(0, topCorrection)
            contentInset = UIEdgeInsets(top: topCorrection, left: 0, bottom: 0, right: 0)
        }
    }
}

class FlippableTextView: UIView {
    private let textLabel = UILabel()
    
    convenience init(text: String) {
        self.init(frame: .zero)
        
        textLabel.text = text
        configureView()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: textLabel.intrinsicContentSize.width + 20, height: textLabel.intrinsicContentSize.height + 20)
    }
}

extension FlippableTextView {
    private func configureView() {
        let container = UIView()
        container.addSubview(textLabel)
        let scrollView = VerticallyCenteredScrollView()
        scrollView.addSubview(container)
        addSubview(scrollView)
        
        textLabel.font = UIFont.systemFont(ofSize: 22)
        textLabel.numberOfLines = 0
        backgroundColor = .white
        
        textLabel.edgeAnchors == container.edgeAnchors + 10
        container.widthAnchor == widthAnchor
        scrollView.edgeAnchors == container.edgeAnchors
        scrollView.edgeAnchors == edgeAnchors
    }
}

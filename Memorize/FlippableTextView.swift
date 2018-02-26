//
//  FlippableTextView.swift
//  Memorize
//
//  Created by Heather Shelley on 2/25/18.
//

import UIKit
import Anchorage

class FlippableTextView: UIView {
    private let textLabel = UILabel()
    
    convenience init(text: String) {
        self.init(frame: .zero)
        
        textLabel.text = text
        configureView()
    }
}

extension FlippableTextView {
    private func configureView() {
        let container = UIView()
        container.addSubview(textLabel)
        let scrollView = UIScrollView()
        scrollView.addSubview(container)
        addSubview(scrollView)
        
        textLabel.font = UIFont.systemFont(ofSize: 20)
        textLabel.numberOfLines = 0
        backgroundColor = .white
        
        textLabel.backgroundColor = .red
        container.backgroundColor = .green
        
        textLabel.edgeAnchors == container.edgeAnchors + 10
        container.widthAnchor == widthAnchor
        scrollView.edgeAnchors == container.edgeAnchors
        scrollView.edgeAnchors == edgeAnchors
    }
}

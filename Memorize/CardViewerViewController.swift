//
//  CardViewerViewController.swift
//  Memorize
//
//  Created by Heather Shelley on 2/25/18.
//

import UIKit
import Anchorage

class CardViewerViewController: UIViewController {
    private let card: Card
    private let questionView: FlippableTextView
    private let answerView: FlippableTextView
    private var isShowingQuestion = true
    private var heightConstraint = NSLayoutConstraint()
    
    init(card: Card) {
        self.card = card
        questionView = FlippableTextView(text: card.question)
        answerView = FlippableTextView(text: card.answer)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print(answerView.bounds.size)
        print(answerView.intrinsicContentSize)
        heightConstraint.constant = answerView.intrinsicContentSize.height
        answerView.setNeedsLayout()
    }
}

extension CardViewerViewController {
    func configureView() {
        [questionView, answerView].forEach { self.view.addSubview($0) }
        
        view.backgroundColor = .gray
        
        questionView.edgeAnchors >= view.safeAreaLayoutGuide.edgeAnchors + 20
        answerView.edgeAnchors == questionView.edgeAnchors
        answerView.centerYAnchor == view.centerYAnchor
        heightConstraint = answerView.heightAnchor == 50 ~ .high
    }
}

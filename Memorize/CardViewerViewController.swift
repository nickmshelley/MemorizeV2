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
    private var questionHeightConstraint = NSLayoutConstraint()
    private var answerHeightConstraint = NSLayoutConstraint()
    
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        questionHeightConstraint.constant = questionView.intrinsicContentSize.height
        answerHeightConstraint.constant = answerView.intrinsicContentSize.height
    }
}

extension CardViewerViewController {
    func configureView() {
        let container = UIView(frame: .zero)
        [questionView, answerView].forEach { container.addSubview($0) }
        view.addSubview(container)
        answerView.isHidden = true
        
        view.backgroundColor = .gray
        
        container.edgeAnchors == view.edgeAnchors
        questionView.edgeAnchors >= container.safeAreaLayoutGuide.edgeAnchors + 20
        answerView.edgeAnchors >= container.safeAreaLayoutGuide.edgeAnchors + 20
        questionView.centerYAnchor == container.centerYAnchor
        answerView.centerYAnchor == container.centerYAnchor
        questionHeightConstraint = questionView.heightAnchor == 50 ~ .high
        answerHeightConstraint = answerView.heightAnchor == 50 ~ .high
    }
    
    @objc func tap() {
        if isShowingQuestion {
            UIView.transition(from: questionView, to: answerView, duration: 0.5, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
        } else {
            UIView.transition(from: answerView, to: questionView, duration: 0.5, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
        }
        
        isShowingQuestion = !isShowingQuestion
    }
}

//
//  CardViewerViewController.swift
//  Memorize
//
//  Created by Heather Shelley on 2/25/18.
//

import UIKit
import Anchorage
import QuartzCore

class CardViewerViewController: UIViewController {
    private let card: Card
    private let titleLabel = UILabel(frame: .zero)
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
        title = "Cards"
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
        let questionAnswerContainer = UIView(frame: .zero)
        [questionView, answerView].forEach { questionAnswerContainer.addSubview($0) }
        view.addSubview(titleLabel)
        view.addSubview(questionAnswerContainer)
        answerView.isHidden = true
        
        view.backgroundColor = .lightGray
        titleLabel.text = "Question"
        titleLabel.font = UIFont.systemFont(ofSize: 28)
        titleLabel.textAlignment = .center
        questionView.layer.cornerRadius = 5
        questionView.clipsToBounds = false
        questionView.layer.shadowOffset = CGSize(width: -2, height: 2)
        questionView.layer.shadowRadius = 2
        questionView.layer.shadowOpacity = 0.5
        answerView.layer.cornerRadius = 5
        answerView.clipsToBounds = false
        answerView.layer.shadowOffset = CGSize(width: -2, height: 2)
        answerView.layer.shadowRadius = 2
        answerView.layer.shadowOpacity = 0.5
        
        titleLabel.horizontalAnchors == view.safeAreaLayoutGuide.horizontalAnchors + 16
        titleLabel.topAnchor == view.safeAreaLayoutGuide.topAnchor + 16
        titleLabel.bottomAnchor == questionAnswerContainer.topAnchor
        questionAnswerContainer.horizontalAnchors == view.safeAreaLayoutGuide.horizontalAnchors
        questionAnswerContainer.bottomAnchor == view.safeAreaLayoutGuide.bottomAnchor
        questionView.edgeAnchors >= questionAnswerContainer.edgeAnchors + 16
        answerView.edgeAnchors >= questionAnswerContainer.edgeAnchors + 16
        questionView.centerYAnchor == questionAnswerContainer.centerYAnchor
        answerView.centerYAnchor == questionAnswerContainer.centerYAnchor
        questionHeightConstraint = questionView.heightAnchor == 50 ~ .high
        answerHeightConstraint = answerView.heightAnchor == 50 ~ .high
    }
    
    @objc func tap() {
        if isShowingQuestion {
            UIView.transition(from: questionView, to: answerView, duration: 0.5, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
            UIView.transition(with: titleLabel, duration: 0.5, options: .transitionCrossDissolve, animations: { self.titleLabel.text = "Answer" }, completion: nil)
        } else {
            UIView.transition(from: answerView, to: questionView, duration: 0.5, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
            UIView.transition(with: titleLabel, duration: 0.5, options: .transitionCrossDissolve, animations: { self.titleLabel.text = "Question" }, completion: nil)
        }
        
        isShowingQuestion = !isShowingQuestion
    }
}

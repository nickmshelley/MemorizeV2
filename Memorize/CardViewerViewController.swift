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
    private let card: Card?
    private let titleLabel = UILabel(frame: .zero)
    private let questionView: FlippableTextView
    private let answerView: FlippableTextView
    private var isShowingQuestion = true
    private var questionHeightConstraint = NSLayoutConstraint()
    private var answerHeightConstraint = NSLayoutConstraint()
    
    init(card: Card?) {
        self.card = card
        let fillerString = "No cards left to review"
        questionView = FlippableTextView(text: card?.question ?? fillerString)
        answerView = FlippableTextView(text: card?.answer ?? fillerString)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cards"
        configureView()
        
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped))
        navigationItem.setRightBarButton(editButton, animated: false)
        
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
    func updateWith(question: String, answer: String, shouldShowQuestion: Bool) {
        questionView.updateText(question)
        
        var answerToDisplay = answer
        if !shouldShowQuestion {
            let charset = CharacterSet(charactersIn: ".").union(.whitespaces).union(.decimalDigits)
            answerToDisplay = answer.components(separatedBy: .newlines)
                .filter { !$0.isEmpty }
                .map { $0.trimmingCharacters(in: charset) }
                .joined(separator: "\n\n")
        }
        
        answerView.updateText(answerToDisplay)
        view.setNeedsLayout()
        
        if shouldShowQuestion {
            showQuestion(duration: 0)
        } else {
            showAnswer(duration: 0)
        }
    }
}

extension CardViewerViewController {
    func configureView() {
        let questionAnswerContainer = UIView(frame: .zero)
        [questionView, answerView].forEach { questionAnswerContainer.addSubview($0) }
        view.addSubview(titleLabel)
        view.addSubview(questionAnswerContainer)
        answerView.isHidden = true
        
        view.backgroundColor = UIColor(white: 0.9, alpha: 1)
        titleLabel.text = "Question"
        titleLabel.font = UIFont.systemFont(ofSize: 28)
        titleLabel.textAlignment = .center
        addShadow(toView: questionView)
        addShadow(toView: answerView)
        
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
    
    private func addShadow(toView view: UIView) {
        view.layer.cornerRadius = 5
        view.clipsToBounds = false
        view.layer.shadowOffset = CGSize(width: -2, height: 2)
        view.layer.shadowRadius = 2
        view.layer.shadowOpacity = 0.5
    }
    
    @objc func tap() {
        if isShowingQuestion {
            showAnswer()
        } else {
            showQuestion()
        }
    }
    
    @objc func editTapped() {
        guard let card = card else { return }
        
        let vc = UINavigationController(rootViewController: EditCardViewController(card: card))
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
    }
    
    func showQuestion(duration: TimeInterval = 0.5) {
        UIView.transition(from: answerView, to: questionView, duration: duration, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
        UIView.transition(with: titleLabel, duration: duration, options: .transitionCrossDissolve, animations: { self.titleLabel.text = "Question" }, completion: nil)
        isShowingQuestion = true
    }
    
    func showAnswer(duration: TimeInterval = 0.5) {
        UIView.transition(from: questionView, to: answerView, duration: duration, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
        UIView.transition(with: titleLabel, duration: duration, options: .transitionCrossDissolve, animations: { self.titleLabel.text = "Answer" }, completion: nil)
        isShowingQuestion = false
    }
}

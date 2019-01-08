//
//  ReviewViewController.swift
//  Memorize
//
//  Created by Nick Shelley on 1/12/18.
//

import UIKit
import Swiftification
import Anchorage

class ReviewViewController: UIViewController {
    private let correctButton = UIButton(type: .custom)
    private let missedButton = UIButton(type: .custom)
    private let undoButton = UIButton(type: .custom)
    private let cardViewerViewController: CardViewerViewController
    private var viewModel: ReviewViewModel
    
    init() {
        viewModel = ReviewViewModel()
        cardViewerViewController = CardViewerViewController(card: nil)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        correctButton.addTarget(self, action: #selector(correctPressed), for: .touchUpInside)
        missedButton.addTarget(self, action: #selector(missedPressed), for: .touchUpInside)
        undoButton.addTarget(self, action: #selector(undoPressed), for: .touchUpInside)
        title = "Review"
        configureView()
        updateCard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.refresh()
        updateCard()
    }
}

extension ReviewViewController {
    private func updateCard() {
        if let card = viewModel.currentCard {
            cardViewerViewController.updateWith(question: card.question, answer: card.answer, shouldShowQuestion: viewModel.isNormal)
            title = "Review (\(String(viewModel.remaining)))"
        } else {
            cardViewerViewController.updateWith(question: "No cards left to review", answer: "No cards left to review", shouldShowQuestion: true)
            title = "Review"
        }
    }
    
    @objc func correctPressed() {
        if viewModel.remaining == 0 && viewModel.currentCard == nil {
            let alert = UIAlertController(title: "Add 10 cards?", message: nil, preferredStyle: .alert)
            let normalAction = UIAlertAction(title: "Normal", style: .default) { _ in
                self.viewModel.addMoreNormal()
                self.updateCard()
            }
            let reverseAction = UIAlertAction(title: "Reverse", style: .default) { _ in
                self.viewModel.addMoreReverse()
                self.updateCard()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(normalAction)
            alert.addAction(reverseAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            viewModel.correct()
            updateCard()
        }
    }
    
    @objc func missedPressed() {
        viewModel.missed()
        updateCard()
    }
    
    @objc func undoPressed() {
        viewModel.undo()
        updateCard()
    }
}

extension ReviewViewController {
    func configureView() {
        addChild(cardViewerViewController)
        let buttonsStackView = UIStackView(arrangedSubviews: [correctButton, undoButton, missedButton], axis: .horizontal, distribution: .equalSpacing)
        view.addSubview(cardViewerViewController.view)
        view.addSubview(buttonsStackView)
        
        view.backgroundColor = .white
        correctButton.setImage(#imageLiteral(resourceName: "checkmark"), for: .normal)
        correctButton.tintColor = .green
        missedButton.setImage(#imageLiteral(resourceName: "missed"), for: .normal)
        missedButton.tintColor = .red
        undoButton.setImage(#imageLiteral(resourceName: "undo"), for: .normal)
        undoButton.tintColor = .blue
        
        [correctButton, missedButton, undoButton].forEach {
            $0.widthAnchor == 50
            $0.heightAnchor == 50
        }
        
        buttonsStackView.heightAnchor == 50
        cardViewerViewController.view.horizontalAnchors == view.horizontalAnchors
        cardViewerViewController.view.topAnchor == view.topAnchor
        buttonsStackView.horizontalAnchors == view.safeAreaLayoutGuide.horizontalAnchors + 12
        buttonsStackView.topAnchor == cardViewerViewController.view.bottomAnchor + 12
        buttonsStackView.bottomAnchor == view.safeAreaLayoutGuide.bottomAnchor - 12
        
        cardViewerViewController.didMove(toParent: self)
    }
}

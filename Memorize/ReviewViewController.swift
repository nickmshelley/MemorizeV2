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
    private var cards: [Card]
    
    init(cards: [Card]) {
        self.cards = cards
        cardViewerViewController = CardViewerViewController(card: cards.random())
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Review"
        configureView()
    }
}

extension ReviewViewController {
    func configureView() {
        addChildViewController(cardViewerViewController)
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
        
        cardViewerViewController.didMove(toParentViewController: self)
    }
}

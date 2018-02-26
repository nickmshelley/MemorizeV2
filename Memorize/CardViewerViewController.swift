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
}

extension CardViewerViewController {
    func configureView() {
        [questionView, answerView].forEach { self.view.addSubview($0) }
        
        view.backgroundColor = .gray
        
        questionView.edgeAnchors == view.safeAreaLayoutGuide.edgeAnchors + 20
        answerView.edgeAnchors == questionView.edgeAnchors
    }
}

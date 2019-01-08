//
//  EditCardViewController.swift
//  Memorize
//
//  Created by Nick Shelley on 1/4/19.
//

import UIKit
import Anchorage

class EditCardViewController: UIViewController {
    private let cardID: String
    private let textField = UITextField(frame: .zero)
    private let textView = UITextView(frame: .zero)
    
    init(card: Card) {
        self.cardID = card.id
        textField.text = card.question
        textView.text = card.answer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Card"
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        navigationItem.setRightBarButton(saveButton, animated: false)
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.setLeftBarButton(cancelButton, animated: false)
        
        configureView()
    }
    
    private func configureView() {
        let container = UIView()
        container.addSubview(textField)
        container.addSubview(textView)
        let scrollView = UIScrollView(frame: .zero)
        scrollView.addSubview(container)
        view.addSubview(scrollView)
        
        view.backgroundColor = .white
        
        textField.horizontalAnchors == container.horizontalAnchors + 10
        textField.topAnchor == container.topAnchor + 10
        textView.horizontalAnchors == container.horizontalAnchors + 10
        textView.topAnchor == textField.bottomAnchor + 10
        textView.bottomAnchor == container.bottomAnchor - 10
        textView.heightAnchor == 350
        textView.font = UIFont.systemFont(ofSize: 18)
        
        container.widthAnchor == scrollView.widthAnchor
        scrollView.edgeAnchors == container.edgeAnchors
        scrollView.edgeAnchors == view.edgeAnchors
    }
    
    @objc func cancelTapped() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func saveTapped() {
        try! UserDataController.shared?.updateCardWithID(cardID, question: textField.text!, answer: textView.text)
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

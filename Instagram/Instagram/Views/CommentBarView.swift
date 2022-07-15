//
//  CommentBarView.swift
//  Instagram
//
//  Created by Caleb Ngai on 7/14/22.
//

import UIKit

protocol CommentBarViewDelegate: AnyObject {
    func CommentBarViewDidTapDone(_ comentBarView: CommentBarView, withText text: String)
}

final class CommentBarView: UIView {
    
    weak var delegate: CommentBarViewDelegate?
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.link, for: .normal)
        return button
    }()
    
    let field: IGTextField = {
        let field = IGTextField()
        field.placeholder = "Comment"
        field.backgroundColor = .tertiarySystemBackground
        return field
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = .systemBackground
        addSubview(field)
        addSubview(button)
        field.delegate = self
        button.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.sizeToFit()
        button.frame = CGRect(
            x: width - button.width - 4 - 2,
            y: (height - button.height)/2,
            width: button.width + 4,
            height: button.height
        )
        field.frame = CGRect(
            x: 2,
            y: (height - 50)/2,
            width: width - button.width - 12,
            height: 50
        )
    }
    
    @objc private func didTapDoneButton() {
        guard let text = field.text,
              !text.trimmingCharacters(in: .whitespaces).isEmpty
        else {return}
        delegate?.CommentBarViewDidTapDone(self, withText: text)
        field.resignFirstResponder()
        field.text = nil
    }
}

extension CommentBarView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        field.resignFirstResponder()
        didTapDoneButton()
        return true
    }
}

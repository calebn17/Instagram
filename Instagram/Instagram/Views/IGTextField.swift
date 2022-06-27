//
//  IGTextField.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/27/22.
//

import UIKit

class IGTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        //Adds some buffer so the cursor/text isnt flush to the textfield
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        leftViewMode = .always
        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.borderColor = UIColor.secondaryLabel.cgColor
        layer.borderWidth = 1
        backgroundColor = .secondarySystemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

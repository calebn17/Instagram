//
//  SignInHeaderView.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/27/22.
//

import UIKit

class SignInHeaderView: UIView {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "text_logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var gradientLayer: CALayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        createGradient()
        addSubview(imageView)

    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //if we want to use x.bounds, then we need to put it in the layoutSubviews func
        gradientLayer?.frame = layer.bounds
        imageView.frame = CGRect(x: width/4, y: 20, width: width/2, height: height - 40)
    }
    
    private func createGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemPink.cgColor]
        layer.addSublayer(gradientLayer)
        self.gradientLayer = gradientLayer
    }
}
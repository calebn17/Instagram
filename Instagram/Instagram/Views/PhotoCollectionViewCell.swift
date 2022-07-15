//
//  PhotoCollectionViewCell.swift
//  Instagram
//
//  Created by Caleb Ngai on 7/5/22.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

//MARK: - Properties
    
    static let identifier = "PhotoCollectionViewCell"
    
//MARK: - SubViews
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .label
        return imageView
    }()
    
//MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }

//MARK: - Configure
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func configure(with image: UIImage?) {
        imageView.image = image
    }
    
    func configure(with url: URL?) {
        imageView.sd_setImage(with: url, completed: nil)
    }
}

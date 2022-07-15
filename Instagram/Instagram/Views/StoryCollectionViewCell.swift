//
//  StoryCollectionViewCell.swift
//  Instagram
//
//  Created by Caleb Ngai on 7/15/22.
//

import UIKit

class StoryCollectionViewCell: UICollectionViewCell {
//MARK: - Properties
    static let identifier = "StoryCollectionViewCell"
 
//MARK: - SubViews
    private let imageView: UIImageView = {
        let imageVew = UIImageView()
        imageVew.layer.masksToBounds = true
        return imageVew
    }()
    
//MARK: - SubViews
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
//MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.addSubview(imageView)
        contentView.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        label.sizeToFit()
        label.frame = CGRect(
            x: 0,
            y: contentView.height - label.height,
            width: contentView.width,
            height: label.height
        )
        
        let imageSize: CGFloat = contentView.height - label.height - 7
        imageView.layer.cornerRadius = imageSize/2
        imageView.frame = CGRect(
            x: (contentView.width - imageSize)/2,
            y: 2,
            width: imageSize,
            height: imageSize
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        imageView.image = nil
    }

//MARK: - Configure
    func configure(with story: Story) {
        label.text = story.username
        imageView.image = story.image
    }
    
}

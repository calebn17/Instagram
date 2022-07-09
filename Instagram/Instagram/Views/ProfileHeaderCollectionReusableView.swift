//
//  ProfileHeaderCollectionReusableView.swift
//  Instagram
//
//  Created by Caleb Ngai on 7/8/22.
//

import UIKit

class ProfileHeaderCollectionReusableView: UICollectionReusableView {
    
//MARK: - Properties
    static let identifier = "ProfileHeaderCollectionReusableView"
    
//MARK: - SubViews
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    public let countContainerView = ProfileHeaderCountView()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        label.text = "Bio label here"
        return label
    }()

//MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(countContainerView)
        addSubview(bioLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
//MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = width/3.5
        imageView.frame = CGRect(x: 5, y: 5, width: imageSize, height: imageSize)
        imageView.layer.cornerRadius = imageSize/2
        countContainerView.frame = CGRect(
            x: imageView.right + 5,
            y: 3,
            width: width - imageView.right - 10,
            height: imageSize
        )
        bioLabel.sizeToFit()
        bioLabel.frame = CGRect(
            x: 5,
            y: imageView.bottom + 10,
            width: width - 10,
            height: bioLabel.height
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        bioLabel.text = nil
    }
    
//MARK: - Configure
    func configure(with viewModel: ProfileHeaderViewModel) {
        imageView.sd_setImage(with: viewModel.profilePictureURL, completed: nil)
        var text = ""
        if let name = viewModel.name {
            text = name + "\n"
        }
        text += viewModel.bio ?? "Welcome to my profile"
        bioLabel.text = text
        
        let containerViewModel = ProfileHeaderCountViewModel(
            followerCount: viewModel.followerCount,
            followingCount: viewModel.followingCount,
            postCount: viewModel.postCount,
            actionType: viewModel.buttonType
        )
        countContainerView.configure(with: containerViewModel)
    }
}

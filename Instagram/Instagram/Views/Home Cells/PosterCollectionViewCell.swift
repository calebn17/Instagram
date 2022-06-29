//
//  PosterCollectionViewCell.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/29/22.
//

import UIKit
import SDWebImage

protocol PosterCollectionViewCellDelegate: AnyObject {
    func PosterCollectionViewCellDelegateDidTapMore(_ cell: PosterCollectionViewCell)
    func PosterCollectionViewCellDelegateDidTapUsername(_ cell: PosterCollectionViewCell)
}

final class PosterCollectionViewCell: UICollectionViewCell {
//MARK: - Properties
    
    static let identifier = "PosterCollectionViewCell"
    weak var delegate: PosterCollectionViewCellDelegate?
    
//MARK: - Elements
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(
            UIImage(
                systemName: "ellipsis",
                withConfiguration:
                    UIImage.SymbolConfiguration(
                        pointSize: 30
                    )
            ),
            for: .normal)
        return button
    }()

//MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(imageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(moreButton)
        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapUsername))
        usernameLabel.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//MARK: - Configure
    override func layoutSubviews() {
        super.layoutSubviews()
        let imagePadding: CGFloat = 4
        let imageSize: CGFloat = contentView.height - (imagePadding*2)
        imageView.frame = CGRect(x: imagePadding, y: imagePadding, width: imageSize, height: imageSize)
        imageView.layer.cornerRadius = imageSize/2
        
        usernameLabel.sizeToFit()
        usernameLabel.frame = CGRect(
            x: imageView.right + 10,
            y: 0,
            width: usernameLabel.width,
            height: contentView.height
        )
        
        moreButton.frame = CGRect(x: (contentView.width - 60), y: (contentView.height - 50)/2, width: 50, height: 50)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = nil
        imageView.image = nil
    }
    
    func configure(with viewModel: PosterCollectionViewCellViewModel) {
        usernameLabel.text = viewModel.username
        imageView.sd_setImage(with: viewModel.profilePictureURL, completed: nil)
    }

//MARK: - Actions
    
    @objc private func didTapMore() {
        delegate?.PosterCollectionViewCellDelegateDidTapMore(self)
    }
    
    @objc private func didTapUsername() {
        delegate?.PosterCollectionViewCellDelegateDidTapUsername(self)
    }
}

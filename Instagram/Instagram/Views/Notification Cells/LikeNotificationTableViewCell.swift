//
//  LikeNotificationTableViewCell.swift
//  Instagram
//
//  Created by Caleb Ngai on 7/7/22.
//

import UIKit

//MARK: - Protocol
protocol LikeNotificationTableViewCellDelegate: AnyObject {
    func likeNotificationTableViewCell(_ cell: LikeNotificationTableViewCell, didTapPostWith viewModel: LikeNotificationCellViewModel)
}

class LikeNotificationTableViewCell: UITableViewCell {
    
    static let identifier = "LikeNotificationTableViewCell"
    weak var delegate: LikeNotificationTableViewCellDelegate?
    private var viewModel: LikeNotificationCellViewModel?
    
//MARK: - SubViews
    private let profilePictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .left
        return label
    }()
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        return label
    }()
    
//MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.clipsToBounds = true
        contentView.addSubview(label)
        contentView.addSubview(profilePictureImageView)
        contentView.addSubview(postImageView)
        contentView.addSubview(dateLabel)
        postImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapPost))
        postImageView.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
//MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        dateLabel.sizeToFit()
        let imageSize: CGFloat = contentView.height/1.5
        profilePictureImageView.frame = CGRect(
            x: 10,
            y: (contentView.height - imageSize)/2,
            width: imageSize,
            height: imageSize
        )
        profilePictureImageView.layer.cornerRadius = imageSize/2
        
        let postSize: CGFloat = contentView.height - 6
        postImageView.frame = CGRect(
            x: contentView.width - postSize - 10,
            y: 3,
            width: postSize,
            height: postSize
        )
        
        let labelSize = label.sizeThatFits(
            CGSize(
                width: contentView.width - profilePictureImageView.right - 25 - postSize,
                height: contentView.height
            )
        )
        label.frame = CGRect(
            x: profilePictureImageView.right + 10,
            y: 0,
            width: labelSize.width,
            height: contentView.height - dateLabel.height - 3
        )
        dateLabel.frame = CGRect(
            x: profilePictureImageView.right + 10,
            y: contentView.height - dateLabel.height - 3,
            width: dateLabel.width,
            height: dateLabel.height
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        profilePictureImageView.image = nil
        postImageView.image = nil
        dateLabel.text = nil
    }
    
//MARK: - Configure
    func configure(with viewModel: LikeNotificationCellViewModel) {
        self.viewModel = viewModel
        profilePictureImageView.sd_setImage(with: viewModel.profilePictureURL, completed: nil)
        label.text = viewModel.username + " liked your post"
        postImageView.sd_setImage(with: viewModel.postURL, completed: nil)
        dateLabel.text = viewModel.date
    }
    
//MARK: - Actions
    @objc private func didTapPost() {
        guard let vm = viewModel else {return}
        delegate?.likeNotificationTableViewCell(self, didTapPostWith: vm)
    }
}

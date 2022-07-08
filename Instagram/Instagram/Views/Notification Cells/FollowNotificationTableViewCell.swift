//
//  FollowNotificationTableViewCell.swift
//  Instagram
//
//  Created by Caleb Ngai on 7/7/22.
//

import UIKit

//MARK: - Protocol
protocol FollowNotificationTableViewCellDelegate: AnyObject {
    func followNotificationTableViewCell(_ cell: FollowNotificationTableViewCell, didTapButton isFollowing: Bool, viewModel: FollowNotificationCellViewModel)
}

class FollowNotificationTableViewCell: UITableViewCell {
    
//MARK: - Properties
    static let identifier = "FollowNotificationTableViewCell"
    weak var delegate: FollowNotificationTableViewCellDelegate?
    private var isFollowing = false
    private var viewModel: FollowNotificationCellViewModel?
    
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
    
    private let followButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        return button
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
        contentView.addSubview(followButton)
        contentView.addSubview(dateLabel)
        followButton.addTarget(self, action: #selector(didTapFollowButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
//MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        followButton.sizeToFit()
        dateLabel.sizeToFit()
        let buttonWidth: CGFloat = max(followButton.width, 75)
        let imageSize: CGFloat = contentView.height/1.5
        profilePictureImageView.frame = CGRect(
            x: 10,
            y: (contentView.height - imageSize)/2,
            width: imageSize,
            height: imageSize
        )
        profilePictureImageView.layer.cornerRadius = imageSize/2
        
        let labelSize = label.sizeThatFits(
            CGSize(
                width: contentView.width - profilePictureImageView.width - buttonWidth - 44,
                height: contentView.height
            )
        )
        label.frame = CGRect(
            x: profilePictureImageView.right + 10,
            y: 0,
            width: labelSize.width,
            height: contentView.height - dateLabel.height - 3
        )
        followButton.frame = CGRect(
            x: contentView.width - buttonWidth - 24,
            y: (contentView.height - followButton.height)/2,
            width: buttonWidth + 14,
            height: followButton.height
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
        followButton.setTitle(nil, for: .normal)
        followButton.backgroundColor = nil
        dateLabel.text = nil
    }
    
    //MARK: - Configure
    func configure(with viewModel: FollowNotificationCellViewModel) {
        self.viewModel = viewModel
        self.isFollowing = viewModel.isCurrentUserFollowing
        label.text = viewModel.username + " started following you."
        profilePictureImageView.sd_setImage(with: viewModel.profilePictureURL, completed: nil)
        updateButton()
        dateLabel.text = viewModel.date
    }
    
    //MARK: - Actions
    @objc private func didTapFollowButton() {
        guard let vm = self.viewModel else {return}
        delegate?.followNotificationTableViewCell(self, didTapButton: !isFollowing, viewModel: vm)
        self.isFollowing = !isFollowing
        updateButton()
    }
    
    private func updateButton() {
        followButton.setTitle(isFollowing ? "Unfollow" : "Follow", for: .normal)
        followButton.backgroundColor = isFollowing ? .tertiarySystemBackground : .link
        followButton.setTitleColor(isFollowing ? .label : .white, for: .normal)
        
        if isFollowing {
            followButton.layer.borderWidth = 1
            followButton.layer.borderColor = UIColor.secondaryLabel.cgColor
        }
    }
}

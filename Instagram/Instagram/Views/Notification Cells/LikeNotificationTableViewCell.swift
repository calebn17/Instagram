//
//  LikeNotificationTableViewCell.swift
//  Instagram
//
//  Created by Caleb Ngai on 7/7/22.
//

import UIKit

class LikeNotificationTableViewCell: UITableViewCell {
    
    static let identifier = "LikeNotificationTableViewCell"
    
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
    
//MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        contentView.addSubview(label)
        contentView.addSubview(profilePictureImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
//MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height/1.5
        profilePictureImageView.frame = CGRect(
            x: 10,
            y: (contentView.height - imageSize)/2,
            width: imageSize,
            height: imageSize
        )
        profilePictureImageView.layer.cornerRadius = imageSize/2
        
        let labelSize = label.sizeThatFits(bounds.size)
        label.frame = CGRect(
            x: profilePictureImageView.right + 10,
            y: 0,
            width: labelSize.width,
            height: contentView.height
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        profilePictureImageView.image = nil
    }
    
//MARK: - Configure
    func configure(with viewModel: LikeNotificationCellViewModel) {
        
    }
}

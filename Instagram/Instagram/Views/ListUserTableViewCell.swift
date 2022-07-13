//
//  ListTableViewCell.swift
//  Instagram
//
//  Created by Caleb Ngai on 7/12/22.
//

import UIKit

class ListUserTableViewCell: UITableViewCell {
    
//MARK: - Properties
    
    static let identifier = "ListUserTableViewCell"

//MARK: - SubViews
    
    private let profilePictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemBackground
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
//MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(profilePictureImageView)
        contentView.addSubview(usernameLabel)
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size: CGFloat = contentView.height/1.3
        profilePictureImageView.frame = CGRect(
            x: 5,
            y: (contentView.height - size)/2,
            width: size,
            height: size
        )
        profilePictureImageView.layer.cornerRadius = size/2
        
        usernameLabel.sizeToFit()
        usernameLabel.frame = CGRect(
            x: profilePictureImageView.right + 10,
            y: 0, width: width,
            height: contentView.height
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = nil
        profilePictureImageView.image = nil
    }
    
    public func configure(with viewModel: ListUserTableViewCellViewModel) {
        usernameLabel.text = viewModel.username
        profilePictureImageView.sd_setImage(with: viewModel.imageURL, completed: nil)
        
        // Debatable whether the View should download data versus putting it in a VC
        StorageManager.shared.downloadProfilePictureURL(for: viewModel.username) {[weak self] url in
            DispatchQueue.main.async {
                self?.profilePictureImageView.sd_setImage(with: url, completed: nil)
            }
        }
    }
}

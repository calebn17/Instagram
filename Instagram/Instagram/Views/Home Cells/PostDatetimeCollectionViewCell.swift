//
//  DatetimeCollectionViewCell.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/29/22.
//

import UIKit

final class PostDatetimeCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostDatetimeCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with viewModel: PostDatetimeCollectionViewCellViewModel) {
        
    }
}

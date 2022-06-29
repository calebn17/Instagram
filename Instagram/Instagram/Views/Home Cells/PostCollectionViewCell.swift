//
//  PostCollectionViewCell.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/29/22.
//

import UIKit

protocol PostCollectionViewCellDelegate: AnyObject {
    func postCollectionViewCellDidLike(_ cell: PostCollectionViewCell)
}

final class PostCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostCollectionViewCell"
    weak var delegate: PostCollectionViewCellDelegate?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(imageView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapToLike))
        tap.numberOfTouchesRequired = 2
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func configure(with viewModel: PostCollectionViewCellViewModel) {
        imageView.sd_setImage(with: viewModel.postURL, completed: nil)
    }
    
    @objc private func didDoubleTapToLike() {
        delegate?.postCollectionViewCellDidLike(self)
    }
}

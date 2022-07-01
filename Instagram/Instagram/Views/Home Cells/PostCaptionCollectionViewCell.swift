//
//  PostCaptionCollectionViewCell.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/29/22.
//

import UIKit

//MARK: - Protocol
protocol PostCaptionCollectionViewCellDelegate: AnyObject {
    func postCaptionCollectionViewCellDidTapCaption(_ cell: PostCaptionCollectionViewCell)
}

final class PostCaptionCollectionViewCell: UICollectionViewCell {

//MARK: - Properties
    static let identifier = "PostCaptionCollectionViewCell"
    weak var delegate: PostCaptionCollectionViewCellDelegate?

//MARK: - SubViews
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        return label
    }()
 
//MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(label)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCaption))
        label.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = label.sizeThatFits(CGSize(width: contentView.bounds.size.width - 12, height: contentView.bounds.size.height))
        label.frame = CGRect(x: 12, y: 3, width: size.width, height: size.height)
    }
  
//MARK: - Configure
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    func configure(with viewModel: PostCaptionCollectionViewCellViewModel) {
        label.text = "\(viewModel.username): \(viewModel.caption ?? "")"
    }
 
//MARK: - Actions
    @objc private func didTapCaption() {
        delegate?.postCaptionCollectionViewCellDidTapCaption(self)
    }
}

//
//  PostViewController.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/27/22.
//

import UIKit

class PostViewController: UIViewController {
    
    //MARK: - Properties
    
    private var collectionView: UICollectionView?
    private var viewModels = [HomeFeedCellType]()
    private let post: Post
    private let username: String
    
    //MARK: - Init
    init(with post: Post, username: String) {
        self.post = post
        self.username = username
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Post"
        view.backgroundColor = .systemBackground
        configureCollectionView()
        fetchPost()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    //MARK: - Fetch Data
    
    private func fetchPost() {
        
        DatabaseManager.shared.getPost(with: post.id, from: username) {[weak self] post in
            guard let post = post else {return}
            guard let username = self?.username else {return}
            
            self?.createViewModel(model: post, username: username) { success in
                if !success {
                    print("failed to create viewmodel")
                }
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData()
                }
            }
        }
    }

    private func createViewModel(model: Post, username: String, completion: @escaping (Bool) -> Void) {
        
        StorageManager.shared.downloadProfilePictureURL(for: username) {[weak self] profilePictureURL in
            
            guard let postURL = URL(string: model.postURLString),
                  let profilePictureURL = profilePictureURL
            else {completion(false); return}
            
            let postData: [HomeFeedCellType] =
            [
                .poster(
                    viewModel:
                        PosterCollectionViewCellViewModel(
                            username: username,
                            profilePictureURL: profilePictureURL)
                ),
                .post(
                    viewModel:
                        PostCollectionViewCellViewModel(
                            postURL: postURL)
                ),
                .actions(
                    viewModel:
                        PostActionsCollectionViewCellViewModel(
                            isLiked: false)
                ),
                .likeCount(
                    viewModel:
                        PostLikesCollectionViewCellViewModel(
                            likers: [])
                ),
                .caption(
                    viewModel:
                        PostCaptionCollectionViewCellViewModel(
                            username: username,
                            caption: model.caption)
                ),
                .timestamp(
                    viewModel:
                        PostDatetimeCollectionViewCellViewModel(date: DateFormatter.formatter.date(from: model.postedDate) ?? Date())
                )
            ]
            self?.viewModels = postData
            completion(true)
        }
    }
}

//MARK: - CollectionView Methods
extension PostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellType = viewModels[indexPath.row]
        
        switch cellType {
            
        case .poster(let viewModel):
            guard let cell =
                    collectionView.dequeueReusableCell(
                        withReuseIdentifier: PosterCollectionViewCell.identifier,
                        for: indexPath)
                    as? PosterCollectionViewCell
            else {fatalError()}
            cell.configure(with: viewModel, index: indexPath.row)
            cell.delegate = self
            return cell
            
        case .post(let viewModel):
            guard let cell =
                    collectionView.dequeueReusableCell(
                        withReuseIdentifier: PostCollectionViewCell.identifier,
                        for: indexPath)
                    as? PostCollectionViewCell
            else {fatalError()}
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
            
        case .actions(let viewModel):
            guard let cell =
                    collectionView.dequeueReusableCell(
                        withReuseIdentifier: PostActionsCollectionViewCell.identifier,
                        for: indexPath)
                    as? PostActionsCollectionViewCell
            else {fatalError()}
            
            // indexPath.section here refers to the specific overall "Post".
            // indexPath.row refers to the celltype (action, like count, etc) in each "Post"
            // So in this case, we need the indexPath.section
            cell.configure(with: viewModel, index: indexPath.row)
            cell.delegate = self
            return cell
            
        case .likeCount(let viewModel):
            guard let cell =
                    collectionView.dequeueReusableCell(
                        withReuseIdentifier: PostLikesCollectionViewCell.identifier,
                        for: indexPath)
                    as? PostLikesCollectionViewCell
            else {fatalError()}
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
            
        case .caption(let viewModel):
            guard let cell =
                    collectionView.dequeueReusableCell(
                        withReuseIdentifier: PostCaptionCollectionViewCell.identifier,
                        for: indexPath)
                    as? PostCaptionCollectionViewCell
            else {fatalError()}
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
            
        case .timestamp(let viewModel):
            guard let cell =
                    collectionView.dequeueReusableCell(
                        withReuseIdentifier: PostDatetimeCollectionViewCell.identifier,
                        for: indexPath)
                    as? PostDatetimeCollectionViewCell
            else {fatalError()}
            cell.configure(with: viewModel)
            
            return cell
        }
    }
}

//MARK: - Poster Cell Methods
extension PostViewController: PosterCollectionViewCellDelegate {
    func PosterCollectionViewCellDelegateDidTapMore(_ cell: PosterCollectionViewCell, index: Int) {
        let sheet = UIAlertController(title: "Post Actions", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Share Post", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                let cellType = self?.viewModels[index]
                switch cellType {
                case .post(viewModel: let viewModel):
                    let vc = UIActivityViewController(
                        activityItems: ["Check out this cool post!", viewModel.postURL],
                        applicationActivities: []
                    )
                    self?.present(vc, animated: true, completion: nil)
                default: break
                }
            }
        }))
        sheet.addAction(UIAlertAction(title: "Report Post", style: .destructive, handler: { _ in
            
        }))
        present(sheet, animated: true)
    }
    
    func PosterCollectionViewCellDelegateDidTapUsername(_ cell: PosterCollectionViewCell) {
        let vc = ProfileViewController(user: User(username: "ye", email: "ye@gmail.com"))
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - Post Cell Methods
extension PostViewController: PostCollectionViewCellDelegate {
    func postCollectionViewCellDidLike(_ cell: PostCollectionViewCell) {
        print("did tap like")
    }
}

//MARK: - Post Actions Cell Methods
extension PostViewController: PostActionsCollectionViewCellDelegate {
    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionsCollectionViewCell, isLiked: Bool, index: Int) {
        //call DB to update like state
    }
    
    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionsCollectionViewCell, index: Int) {
        //        let vc = PostViewController()
        //        vc.title = "Comment"
        //        navigationController?.pushViewController(vc, animated: true)
    }
    
    func postActionsCollectionViewCellDidTapShare(_ cell: PostActionsCollectionViewCell, index: Int) {
        
        let cellType = viewModels[index]
        switch cellType {
        case .post(viewModel: let viewModel):
            let vc = UIActivityViewController(
                activityItems: ["Check out this cool post!", viewModel.postURL],
                applicationActivities: []
            )
            present(vc, animated: true, completion: nil)
        default: break
        }
        
    }
}

//MARK: - Post Likes Cell Methods
extension PostViewController: PostLikesCollectionViewCellDelegate {
    func PostLikesCollectionViewCellDidTapLikeCount(_ cell: PostLikesCollectionViewCell) {
        let vc = ListViewController(type: .likers(usernames: []))
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - PostCaption Cell Methods
extension PostViewController: PostCaptionCollectionViewCellDelegate {
    func postCaptionCollectionViewCellDidTapCaption(_ cell: PostCaptionCollectionViewCell) {
        
    }
}

//MARK: - Configure CollectionView
extension PostViewController {
    private func configureCollectionView() {
        //sectionHeight is all the heights of the items combined
        let sectionHeight: CGFloat = 240 + view.width
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { index, _ in
                // Item
                let posterItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(60)
                    )
                )
                let postItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalWidth(1)
                    )
                )
                let actionsItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(40)
                    )
                )
                let likeCountItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(40)
                    )
                )
                let captionItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(60)
                    )
                )
                let timestampItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(40)
                    )
                )
                
                //Group
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(sectionHeight)
                    ),
                    subitems: [
                        posterItem,
                        postItem,
                        actionsItem,
                        likeCountItem,
                        captionItem,
                        timestampItem
                    ]
                )
                
                //Section
                let section = NSCollectionLayoutSection(group: group)
                //adding some padding between sections
                section.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 0, bottom: 10, trailing: 0)
                return section
            })
        )
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PosterCollectionViewCell.self, forCellWithReuseIdentifier: PosterCollectionViewCell.identifier)
        collectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
        collectionView.register(PostActionsCollectionViewCell.self, forCellWithReuseIdentifier: PostActionsCollectionViewCell.identifier)
        collectionView.register(PostLikesCollectionViewCell.self, forCellWithReuseIdentifier: PostLikesCollectionViewCell.identifier)
        collectionView.register(PostCaptionCollectionViewCell.self, forCellWithReuseIdentifier: PostCaptionCollectionViewCell.identifier)
        collectionView.register(PostDatetimeCollectionViewCell.self, forCellWithReuseIdentifier: PostDatetimeCollectionViewCell.identifier)
        collectionView.register(CommentCollectionViewCell.self, forCellWithReuseIdentifier: CommentCollectionViewCell.identifier)
        self.collectionView = collectionView
    }
}



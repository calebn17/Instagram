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
    private var viewModels = [SinglePostCellType]()
    private let post: Post
    private let owner: String
    private var keyboardAppearObserver: NSObjectProtocol?
    private var keyboardHideObserver: NSObjectProtocol?
    
    //MARK: - SubViews
    
    private let commentBarView = CommentBarView()
    
    //MARK: - Init
    init(with post: Post, username: String) {
        self.post = post
        self.owner = username
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
        view.addSubview(commentBarView)
        commentBarView.delegate = self
        fetchPost()
        observeKeyboardChange()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
        commentBarView.frame = CGRect(
            x: 0,
            y: view.height - view.safeAreaInsets.bottom - 70,
            width: view.width,
            height: 70
        )
    }
    
    //MARK: - Configure
    
    private func observeKeyboardChange() {
        keyboardAppearObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main) { notification in
                guard let userInfo = notification.userInfo,
                      let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
                else {return}
                let keyboardHeight = frame.height
                UIView.animate(withDuration: 0.2) {
                    self.commentBarView.frame = CGRect(
                        x: 0,
                        y: self.view.height - 70 - keyboardHeight,
                        width: self.view.width,
                        height: 70
                    )
                }
            }
        keyboardHideObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main) { _ in
                self.commentBarView.frame = CGRect(
                    x: 0,
                    y: self.view.height - self.view.safeAreaInsets.bottom - 70,
                    width: self.view.width,
                    height: 70
                )
            }
    }
    
    //MARK: - Fetch Data
    
    private func fetchPost() {
        
        DatabaseManager.shared.getPost(with: post.id, from: owner) {[weak self] post in
            guard let post = post else {return}
            guard let username = self?.owner else {return}
            
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
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {return}
        
        StorageManager.shared.downloadProfilePictureURL(for: username) {[weak self] profilePictureURL in
            
            guard let postURL = URL(string: model.postURLString),
                  let profilePictureURL = profilePictureURL,
                  let strongSelf = self
            else {
                completion(false)
                return
            }
            
            let isLiked = model.likers.contains(currentUsername)
            
            DatabaseManager.shared.getComments(postID: strongSelf.post.id, owner: strongSelf.owner) { comments in
                var postData: [SinglePostCellType] =
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
                                isLiked: isLiked)
                    ),
                    .likeCount(
                        viewModel:
                            PostLikesCollectionViewCellViewModel(
                                likers: model.likers)
                    ),
                    .caption(
                        viewModel:
                            PostCaptionCollectionViewCellViewModel(
                                username: username,
                                caption: model.caption)
                    ),
                ]
                
                if let comment = comments.first {
                    postData.append(
                        .comment(viewModel: comment)
                    )
                }
                
                postData.append(
                    .timestamp(
                        viewModel:
                            PostDatetimeCollectionViewCellViewModel(date: DateFormatter.formatter.date(from: model.postedDate) ?? Date())
                    )
                )
                
                self?.viewModels = postData
                completion(true)
            }
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
            cell.configure(with: viewModel, index: indexPath.row)
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
            cell.configure(with: viewModel, index: indexPath.section)
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
        case .comment(let viewModel):
            guard let cell =
                    collectionView.dequeueReusableCell(
                        withReuseIdentifier: CommentCollectionViewCell.identifier,
                        for: indexPath)
                    as? CommentCollectionViewCell
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
    /// Double Tap to like
    func postCollectionViewCellDidLike(_ cell: PostCollectionViewCell, index: Int) {
        DatabaseManager.shared.updateLike(
            state: .like,
            postID: post.id,
            owner: owner) { success in
            if !success {
                print("somthing went wrong when liking/unliking")
            }
        }
    }
}

//MARK: - Post Actions Cell Methods
extension PostViewController: PostActionsCollectionViewCellDelegate {
    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionsCollectionViewCell, isLiked: Bool, index: Int) {
        
        let state: DatabaseManager.LikeState = isLiked ? .like : .unlike
        
        DatabaseManager.shared.updateLike(
            state: state,
            postID: post.id,
            owner: owner) { success in
            if !success {
                print("somthing went wrong when liking/unliking")
            }
        }
    }
    
    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionsCollectionViewCell, index: Int) {
        commentBarView.field.becomeFirstResponder()
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
    func PostLikesCollectionViewCellDidTapLikeCount(_ cell: PostLikesCollectionViewCell, index: Int) {
        let vc = ListViewController(type: .likers(usernames: post.likers))
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - PostCaption Cell Methods
extension PostViewController: PostCaptionCollectionViewCellDelegate {
    func postCaptionCollectionViewCellDidTapCaption(_ cell: PostCaptionCollectionViewCell) {
        
    }
}

extension PostViewController: CommentBarViewDelegate {
    func CommentBarViewDidTapDone(_ comentBarView: CommentBarView, withText text: String) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {return}
        DatabaseManager.shared.insertComments(
            comment: Comment(username: currentUsername,
                             comment: text,
                             dateString: String.date(from: Date()) ?? ""
                            ),
            postID: post.id,
            owner: owner) { success in
                DispatchQueue.main.async {
                    guard success else {return}
                    print(success)
                }
            }
    }
}

//MARK: - Configure CollectionView
extension PostViewController {
    private func configureCollectionView() {
        //sectionHeight is all the heights of the items combined
        let sectionHeight: CGFloat = 300 + view.width
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
                let commentItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(60)
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
                        commentItem,
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
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        self.collectionView = collectionView
    }
}



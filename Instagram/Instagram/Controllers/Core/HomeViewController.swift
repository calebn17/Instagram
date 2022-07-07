//
//  ViewController.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/27/22.
//

import UIKit

final class HomeViewController: UIViewController {
    
//MARK: - Properties
    
    private var collectionView: UICollectionView?
    
    //2x2 array: collection of IG Posts, where each post is a collection of cell types
    private var viewModels = [[HomeFeedCellType]]()
            
//MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Instagram"
        view.backgroundColor = .systemBackground
        configureCollectionView()
        fetchPosts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
//MARK: - Fetch Data
    
    private func fetchPosts() {
        
        guard let username = UserDefaults.standard.string(forKey: "username") else {return}
        DatabaseManager.shared.posts(for: username) {[weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    let group = DispatchGroup()
                    
                    posts.forEach { model in
                        group.enter()
                        self?.createViewModel(model: model, username: username) { success in
                            defer {
                                group.leave()
                            }
                            if !success {
                                print("failed to create viewmodel")
                            }
                        }
                    }
                    group.notify(queue: .main) {
                        self?.collectionView?.reloadData()
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    private func createViewModel(model: Post, username: String, completion: @escaping (Bool) -> Void) {
        
        StorageManager.shared.downloadProfilePictureURL(for: username) {[weak self] profilePictureURL in
            
            guard let postURL = URL(string: model.postURLString),
                  let profilePictureURL = profilePictureURL
            else {return}

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
            self?.viewModels.append(postData)
            completion(true)
        }
    }
}

//MARK: - CollectionView Methods
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let colors: [UIColor] = [.red, .green, .blue, .systemPink, .purple, .cyan]
        
        let cellType = viewModels[indexPath.section][indexPath.row]
        
        switch cellType {
            
        case .poster(let viewModel):
            guard let cell =
                    collectionView.dequeueReusableCell(
                        withReuseIdentifier: PosterCollectionViewCell.identifier,
                        for: indexPath)
                    as? PosterCollectionViewCell
            else {fatalError()}
            cell.configure(with: viewModel)
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
            cell.configure(with: viewModel)
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
extension HomeViewController: PosterCollectionViewCellDelegate {
    func PosterCollectionViewCellDelegateDidTapMore(_ cell: PosterCollectionViewCell) {
        let sheet = UIAlertController(title: "Post Actions", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Share Post", style: .default, handler: { _ in
            
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
extension HomeViewController: PostCollectionViewCellDelegate {
    func postCollectionViewCellDidLike(_ cell: PostCollectionViewCell) {
        print("did tap like")
    }
}

//MARK: - Post Actions Cell Methods
extension HomeViewController: PostActionsCollectionViewCellDelegate {
    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionsCollectionViewCell, isLiked: Bool) {
        //call DB to update like state
    }
    
    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionsCollectionViewCell) {
//        let vc = PostViewController()
//        vc.title = "Comment"
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    func postActionsCollectionViewCellDidTapShare(_ cell: PostActionsCollectionViewCell) {
        let vc = UIActivityViewController(activityItems: ["Sharing from Instagram"], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
}

//MARK: - Post Likes Cell Methods
extension HomeViewController: PostLikesCollectionViewCellDelegate {
    func PostLikesCollectionViewCellDidTapLikeCount(_ cell: PostLikesCollectionViewCell) {
        let vc = ListViewController()
        vc.title = "Liked By"
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - PostCaption Cell Methods
extension HomeViewController: PostCaptionCollectionViewCellDelegate {
    func postCaptionCollectionViewCellDidTapCaption(_ cell: PostCaptionCollectionViewCell) {
       
    }
}

//MARK: - Configure CollectionView
extension HomeViewController {
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
        self.collectionView = collectionView
    }
}

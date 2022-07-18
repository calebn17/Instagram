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
    private var allPosts: [(post: Post, owner: String)] = []
    private var observer: NSObjectProtocol?
            
//MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Instagram"
        view.backgroundColor = .systemBackground
        configureCollectionView()
        fetchPosts()
        observeDidPost()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
//MARK: - Fetch Data
    
    private func fetchPosts() {
        
        guard let username = UserDefaults.standard.string(forKey: "username") else {return}
        
        let userGroup = DispatchGroup()
        userGroup.enter()
        
        var allPosts: [(post: Post, owner: String)] = []
        
        DatabaseManager.shared.following(for: username) { followerUsernames in
            defer {
                userGroup.leave()
            }
            let users = followerUsernames + [username]
            for current in users {
                userGroup.enter()
                DatabaseManager.shared.posts(for: current) { result in
                    DispatchQueue.main.async {
                        defer {
                            userGroup.leave()
                        }
                        switch result {
                        case .success(let posts):
                            allPosts.append(contentsOf: posts.compactMap({
                                (post: $0, owner: current)
                            }))
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            }
        }
        userGroup.notify(queue: .main) {
            let group = DispatchGroup()
            self.allPosts = allPosts
            allPosts.forEach { model in
                group.enter()
                self.createViewModel(model: model.post, username: model.owner) { success in
                    defer {
                        group.leave()
                    }
                    if !success {
                        print("failed to create viewModel")
                    }
                }
            }
            group.notify(queue: .main) {
                self.sortData()
                self.collectionView?.reloadData()
            }
        }
    }
    
    private func sortData() {
        allPosts = allPosts.sorted(by: { first, second in
            let date1 = first.post.date
            let date2 = second.post.date
            return date1 > date2
        })
        self.viewModels = self.viewModels.sorted(by: { first, second in
            var date1: Date?
            var date2: Date?
            
            first.forEach { type in
                switch type {
                case .timestamp(viewModel: let vm):
                    date1 = vm.date
                default: break
                }
            }
            second.forEach {type in
                    switch type {
                    case .timestamp(viewModel: let vm):
                        date2 = vm.date
                    default: break
                    }
            }
            if let date1 = date1,
               let date2 = date2 {
                return date1 > date2
            }
            return false
        })
    }

    private func observeDidPost() {
        observer = NotificationCenter.default.addObserver(
            forName: .didPostNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                self?.viewModels.removeAll()
                self?.fetchPosts()
            }
    }
    
    private func createViewModel(model: Post, username: String, completion: @escaping (Bool) -> Void) {
        
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {return}
        
        StorageManager.shared.downloadProfilePictureURL(for: username) {[weak self] profilePictureURL in
            
            guard let postURL = URL(string: model.postURLString),
                  let profilePictureURL = profilePictureURL
            else {completion(false); return}
            
            let isLiked = model.likers.contains(currentUsername)

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
        
        let cellType = viewModels[indexPath.section][indexPath.row]
        
        switch cellType {
            
        case .poster(let viewModel):
            guard let cell =
                    collectionView.dequeueReusableCell(
                        withReuseIdentifier: PosterCollectionViewCell.identifier,
                        for: indexPath)
                    as? PosterCollectionViewCell
            else {fatalError()}
            cell.configure(with: viewModel, index: indexPath.section)
            cell.delegate = self
            return cell
            
        case .post(let viewModel):
            guard let cell =
                    collectionView.dequeueReusableCell(
                        withReuseIdentifier: PostCollectionViewCell.identifier,
                        for: indexPath)
                    as? PostCollectionViewCell
            else {fatalError()}
            cell.configure(with: viewModel, index: indexPath.section)
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
            cell.configure(with: viewModel, index: indexPath.section)
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
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: StoryHeaderView.identifier,
                for: indexPath)
                as? StoryHeaderView
        else {return UICollectionReusableView()}
        
        let viewModel = StoriesViewModel(
            stories: [
                Story(username: "jeffbezos",image: UIImage(named: "test")),
                Story(username: "jeffbezos",image: UIImage(named: "test")),
                Story(username: "jeffbezos",image: UIImage(named: "test")),
                Story(username: "jeffbezos",image: UIImage(named: "test")),
                Story(username: "jeffbezos",image: UIImage(named: "test")),
                Story(username: "jeffbezos",image: UIImage(named: "test")),
                Story(username: "jeffbezos",image: UIImage(named: "test")),
                Story(username: "jeffbezos",image: UIImage(named: "test"))
            ]
        )
        headerView.configure(with: viewModel)
        return headerView
    }
}

//MARK: - Poster Cell Methods
extension HomeViewController: PosterCollectionViewCellDelegate {
    func PosterCollectionViewCellDelegateDidTapMore(_ cell: PosterCollectionViewCell, index: Int) {
        let sheet = UIAlertController(title: "Post Actions", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Share Post", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                let section = self?.viewModels[index]
                section?.forEach({ cellType in
                    switch cellType {
                    case .post(viewModel: let viewModel):
                        let vc = UIActivityViewController(
                            activityItems: ["Check out this cool post!", viewModel.postURL],
                            applicationActivities: []
                        )
                        self?.present(vc, animated: true, completion: nil)
                    default: break
                    }
                })
                
            }
        }))
        sheet.addAction(UIAlertAction(title: "Report Post", style: .destructive, handler: { _ in
            // Report
            AnalyticsManager.shared.logFeedInteraction(.reported)
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
    /// Double Tap
    func postCollectionViewCellDidLike(_ cell: PostCollectionViewCell, index: Int) {
        
        AnalyticsManager.shared.logFeedInteraction(.doubleTapToLike)
        let tuple = allPosts[index]
        
        DatabaseManager.shared.updateLike(
            state: .like,
            postID: tuple.post.id,
            owner: tuple.owner) { success in
                
            if !success {
                print("Something went wrong... could not update like status")
            }
        }
    }
}

//MARK: - Post Actions Cell Methods
extension HomeViewController: PostActionsCollectionViewCellDelegate {
    func postActionsCollectionViewCellDidTapLike(_ cell: PostActionsCollectionViewCell, isLiked: Bool, index: Int) {
        
        HapticsManager.shared.vibrateForSelection()
        let state: DatabaseManager.LikeState = isLiked ? .like : .unlike
        
        let tuple = allPosts[index]
        
        DatabaseManager.shared.updateLike(
            state: state,
            postID: tuple.post.id,
            owner: tuple.owner) { success in
                
            if !success {
                print("Something went wrong... could not update like status")
            }
        }
    }
    
    func postActionsCollectionViewCellDidTapComment(_ cell: PostActionsCollectionViewCell, index: Int) {
        
        AnalyticsManager.shared.logFeedInteraction(.comment)
        let tuple = allPosts[index]
        
        HapticsManager.shared.vibrateForSelection()
        
        let vc = PostViewController(with: tuple.post, username: tuple.owner)
        vc.title = "Comment"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func postActionsCollectionViewCellDidTapShare(_ cell: PostActionsCollectionViewCell, index: Int) {
        
        AnalyticsManager.shared.logFeedInteraction(.share)
        
        let section = viewModels[index]
        section.forEach { cellType in
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
}

//MARK: - Post Likes Cell Methods
extension HomeViewController: PostLikesCollectionViewCellDelegate {
    func PostLikesCollectionViewCellDidTapLikeCount(_ cell: PostLikesCollectionViewCell, index: Int) {
        
        HapticsManager.shared.vibrateForSelection()
        
        let vc = ListViewController(type: .likers(usernames: allPosts[index].post.likers))
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
                
                if index == 0 {
                    section.boundarySupplementaryItems = [
                        NSCollectionLayoutBoundarySupplementaryItem(
                            layoutSize: NSCollectionLayoutSize(
                                widthDimension: .fractionalWidth(1),
                                heightDimension: .fractionalWidth(0.3)
                            ),
                            elementKind: UICollectionView.elementKindSectionHeader,
                            alignment: .top
                        )
                    ]
                }
                
                // adding some padding between sections
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
        collectionView.register(StoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: StoryHeaderView.identifier)
        self.collectionView = collectionView
    }
}

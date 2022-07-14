//
//  ProfileViewController.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/27/22.
//

import UIKit

final class ProfileViewController: UIViewController {

//MARK: - Properties
    
    private let user: User
    private var isCurrentUser: Bool {
        return user.username.lowercased() == UserDefaults.standard.string(forKey: "username")?.lowercased()
    }
    private var headerViewModel: ProfileHeaderViewModel?
    private var posts: [Post] = []
    private var observer: NSObjectProtocol?
    
//MARK: - SubViews
    
    private var collectionView: UICollectionView?
    
//MARK: - Init
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = user.username.uppercased()
        view.backgroundColor = .systemBackground
        configureNavBar()
        configureCollectionView()
        fetchProfileInfo()
        
        if isCurrentUser{
            observer = NotificationCenter.default.addObserver(
                forName: .didPostNotification,
                object: nil,
                queue: .main) { [weak self] _ in
                    self?.posts.removeAll()
                    self?.fetchProfileInfo()
                    self?.collectionView?.reloadData()
                }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }

//MARK: - Configure
    
    private func configureNavBar() {
        if isCurrentUser{
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "gear"),
                style: .done,
                target: self,
                action: #selector(didTapSettings)
            )
        }
    }
    
//MARK: - API
    
    private func fetchProfileInfo() {
        let group = DispatchGroup()
        
        // Fetch Posts
        group.enter()
        DatabaseManager.shared.posts(for: user.username) { [weak self] result in
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let posts):
                self?.posts = posts
                
            case .failure:break
            }
        }
        
        // Fetch Profile Header Info
        
        var profilePictureURL: URL?
        var buttonType: ProfileButtonType = .edit
        var posts = 0
        var followers = 0
        var following = 0
        var name: String?
        var bio: String?
        
        
        
        // Counts (3)
        group.enter()
        DatabaseManager.shared.getUserCounts(username: user.username) { result in
            defer {
                group.leave()
            }
            posts = result.posts
            followers = result.follower
            following = result.following
        }
        
        // Bio, name
        DatabaseManager.shared.getUserInfo(username: user.username) { userInfo in
            name = userInfo?.name
            bio = userInfo?.bio
        }
        
        // Profile picture url
        group.enter()
        StorageManager.shared.downloadProfilePictureURL(for: user.username) { url in
            defer {
                group.leave()
            }
            profilePictureURL = url
        }
        
        // If viewed profile is not for current user...
        if !isCurrentUser {
            group.enter()
            // ...get follow state
            DatabaseManager.shared.isFollowing(targetUsername: user.username) { isFollowing in
                defer {
                    group.leave()
                }
                buttonType = .follow(isFollowing: isFollowing)
            }
        }
        
        group.notify(queue: .main) {
            self.headerViewModel = ProfileHeaderViewModel(
                profilePictureURL: profilePictureURL,
                followerCount: followers,
                followingCount: following,
                postCount: posts,
                buttonType: buttonType,
                name: name,
                bio: bio
            )
            self.collectionView?.reloadData()
        }
    }

//MARK: - Actions
    
    @objc private func didTapSettings() {
        let vc = SettingsViewController()
        present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
}

//MARK: - CollectionView Methods
extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell
        else {fatalError()}
        cell.configure(with: URL(string: posts[indexPath.row].postURLString))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let post = posts[indexPath.row]
        let vc = PostViewController(with: post, username: user.username)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier,
                for: indexPath
              ) as? ProfileHeaderCollectionReusableView
        else {return UICollectionReusableView()}
        
        if let viewModel = headerViewModel {
            headerView.countContainerView.delegate = self
            headerView.configure(with: viewModel)
        }
        headerView.delegate = self
        return headerView
    }
}

//MARK: - ProfileHeaderCountView Methods
extension ProfileViewController: ProfileHeaderCountViewDelegate {
    func profileHeaderCountViewDidTapFollowers(_ containerView: ProfileHeaderCountView) {
        let vc = ListViewController(type: .followers(user: user))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func profileHeaderCountViewDidTapFollowing(_ containerView: ProfileHeaderCountView) {
        let vc = ListViewController(type: .following(user: user))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func profileHeaderCountViewDidTapPosts(_ containerView: ProfileHeaderCountView) {
        guard posts.count >= 18 else {return}
        collectionView?.setContentOffset(CGPoint(x: 0, y: view.width * 0.4), animated: true)
    }
    
    func profileHeaderCountViewDidTapEditProfile(_ containerView: ProfileHeaderCountView) {
        let vc = EditProfileViewController()
        vc.completion = {[weak self] in
            // refetch header info
            self?.headerViewModel = nil
            self?.fetchProfileInfo()
            
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
    }
    
    func profileHeaderCountViewDidTapFollow(_ containerView: ProfileHeaderCountView) {
        DatabaseManager.shared.updateRelationship(state: .follow, for: user.username) { [weak self] success in
            if !success {
                print("failed to follow")
                DispatchQueue.main.async {
                    // Reload data here to revert the follow button to it's proper state
                    self?.collectionView?.reloadData()
                }
            }
        }
    }
    
    func profileHeaderCountViewDidTapUnfollow(_ containerView: ProfileHeaderCountView) {
        DatabaseManager.shared.updateRelationship(state: .unfollow, for: user.username) { [weak self] success in
            if !success {
                print("failed to unfollow")
                DispatchQueue.main.async {
                    // Reload data here to revert the follow button to it's proper state
                    self?.collectionView?.reloadData()
                }
            }
        }
    }
}

//MARK: - ProfileheaderCollectionReusableView Methods
extension ProfileViewController: ProfileHeaderCollectionReusableViewDelegate {
    func profileHeaderCollectionReusableViewDidTapProfilePicture(_ header: ProfileHeaderCollectionReusableView) {
        // User can only change their own profile picture (only when they view their own profile)
        guard isCurrentUser else {return}
        
        let sheet = UIAlertController(
            title: "Change profile picture",
            message: "Update your profile picture",
            preferredStyle: .actionSheet
        )
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: {[weak self] _ in
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.allowsEditing = true
                picker.delegate = self
                self?.present(picker, animated: true, completion: nil)
            }
        }))
        sheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: {[weak self] _ in
            DispatchQueue.main.async {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.allowsEditing = true
                picker.delegate = self
                self?.present(picker, animated: true, completion: nil)
            }
        }))
        present(sheet, animated: true, completion: nil)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {return}
        StorageManager.shared.uploadProfilePicture(username: user.username, data: image.pngData()) {[weak self] success in
            if success {
                self?.headerViewModel = nil
                self?.posts = []
                //Dont need to push to the main thread in this block because fetchProfileInfo already does that
                self?.fetchProfileInfo()
            }
        }
    }
}

//MARK: - Configure Collection View
extension ProfileViewController {
    private func configureCollectionView() {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(
                sectionProvider: { index, _  in
                    
                    let item = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalHeight(1)
                        )
                    )
                    item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
                    
                    let group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalWidth(0.33)
                        ),
                        subitem: item,
                        count: 3
                    )
                    let section = NSCollectionLayoutSection(group: group)
                    
                    section.boundarySupplementaryItems = [
                        NSCollectionLayoutBoundarySupplementaryItem(
                            layoutSize: NSCollectionLayoutSize(
                                widthDimension: .fractionalWidth(1),
                                heightDimension: .fractionalWidth(0.66)
                            ),
                            elementKind: UICollectionView.elementKindSectionHeader,
                            alignment: .top
                        )
                    ]
                    return section
                }
            )
        )
        collectionView.register(
            PhotoCollectionViewCell.self,
            forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier
        )
        collectionView.register(
            ProfileHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier
        )
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        self.collectionView = collectionView
    }
}

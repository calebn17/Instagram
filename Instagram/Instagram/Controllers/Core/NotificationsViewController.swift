//
//  NotificationsViewController.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/27/22.
//

import UIKit

final class NotificationsViewController: UIViewController {

//MARK: - Properties
    private var viewModels: [NotificationCellType] = []
    private var models: [IGNotification] = []

//MARK: - Subviews
    private let noActivityLabel: UILabel = {
        let label = UILabel()
        label.text = "No Notifications"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(LikeNotificationTableViewCell.self, forCellReuseIdentifier: LikeNotificationTableViewCell.identifier)
        tableView.register(FollowNotificationTableViewCell.self, forCellReuseIdentifier: FollowNotificationTableViewCell.identifier)
        tableView.register(CommentNotificationTableViewCell.self, forCellReuseIdentifier: CommentNotificationTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()

//MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notification"
        view.backgroundColor = .systemBackground
        configureTableView()
        view.addSubview(noActivityLabel)
        fetchNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noActivityLabel.sizeToFit()
        noActivityLabel.center = view.center
    }
    
//MARK: - Configure
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }

//MARK: - API
    private func fetchNotifications() {
        NotificationsManager.shared.getNotifications {[weak self] models in
            
            DispatchQueue.main.async {
                self?.models = models
                self?.createViewModels()
            }
        }
    }
    
    private func createViewModels() {
        models.forEach { model in
            guard let type = NotificationsManager.T(rawValue: model.notificationType),
                  let profilePictureURL = URL(string: model.profilePictureURLString)
            else {return}
            let username = model.username
            
            switch type {
            case .like:
                guard let postURL = URL(string: model.postURLString ?? "") else {return}
                viewModels.append(
                    .like(
                        viewModel:
                            LikeNotificationCellViewModel(
                                username: username,
                                profilePictureURL: profilePictureURL,
                                postURL: postURL,
                                date: model.dateString
                            )
                    )
                )
            case .comment:
                guard let postURL = URL(string: model.postURLString ?? "") else {return}
                viewModels.append(
                    .comment(
                        viewModel:
                            CommentNotificationCellViewModel(
                                username: username,
                                profilePictureURL: profilePictureURL,
                                postURL: postURL,
                                date: model.dateString
                            )
                    )
                )
            case .follow:
                guard let isFollowing = model.isFollowing else {return}
                viewModels.append(
                    .follow(
                        viewModel:
                            FollowNotificationCellViewModel(
                                username: username,
                                profilePictureURL: profilePictureURL,
                                isCurrentUserFollowing: isFollowing,
                                date: model.dateString
                            )
                    )
                )
            }
        }
        if viewModels.isEmpty {
            noActivityLabel.isHidden = false
            tableView.isHidden = true
        }
        else {
            noActivityLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    private func mockData() {
        tableView.isHidden = false
        
        guard let postURL = URL(string: "https://iosacademy.io/assets/images/courses/swiftui.png"),
              let iconURL = URL(string: "https://iosacademy.io/assets/images/brand/icon.jpg")
        else {return}
        
        viewModels = [
            .like(viewModel:
                    LikeNotificationCellViewModel(
                        username: "kyliejenner",
                        profilePictureURL: iconURL,
                        postURL:postURL,
                        date: "March 12"
                    )
                 ),
            .comment(
                viewModel:
                    CommentNotificationCellViewModel(
                        username: "jeffbezos",
                        profilePictureURL: iconURL,
                        postURL: postURL,
                        date: "March 12"
                    )
            ),
            .follow(
                viewModel:
                    FollowNotificationCellViewModel(
                        username: "zuckerberg",
                        profilePictureURL: iconURL,
                        isCurrentUserFollowing: true,
                        date: "March 12"
                    )
            )
        ]
        tableView.reloadData()
    }
}

//MARK: - TableView Methods
extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = viewModels[indexPath.row]
        switch cellType {
            
        case .follow(let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FollowNotificationTableViewCell.identifier, for: indexPath)
                    as? FollowNotificationTableViewCell
            else {return UITableViewCell()}
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
            
        case .like(viewModel: let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LikeNotificationTableViewCell.identifier, for: indexPath)
                    as? LikeNotificationTableViewCell
            else {return UITableViewCell()}
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
            
        case .comment(viewModel: let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentNotificationTableViewCell.identifier, for: indexPath)
                    as? CommentNotificationTableViewCell
            else {return UITableViewCell()}
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cellType = viewModels[indexPath.row]
        let username: String
        
        switch cellType {
        case .follow(viewModel: let viewModel):
            username = viewModel.username
        case .like(viewModel: let viewModel):
            username = viewModel.username
        case .comment(viewModel: let viewModel):
            username = viewModel.username
        }
        DatabaseManager.shared.findUser(username: username) { [weak self] user in
            guard let user = user else {return}
            
            DispatchQueue.main.async {
                let vc = ProfileViewController(user: user)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

//MARK: - Notification Cell Methods
extension NotificationsViewController: FollowNotificationTableViewCellDelegate, CommentNotificationTableViewCellDelegate, LikeNotificationTableViewCellDelegate {
    
    func followNotificationTableViewCell(_ cell: FollowNotificationTableViewCell, didTapButton isFollowing: Bool, viewModel: FollowNotificationCellViewModel) {
        let username = viewModel.username
        print("Request follow = \(isFollowing) for user = \(username)")
        DatabaseManager.shared.updateRelationship(state: isFollowing ? .follow : .unfollow, for: username) {[weak self] success in
            if !success {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Oops", message: "Unable to perform action.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func likeNotificationTableViewCell(_ cell: LikeNotificationTableViewCell, didTapPostWith viewModel: LikeNotificationCellViewModel) {
        guard let index = viewModels.firstIndex(where: {
            switch $0 {
            case .comment, .follow:
                return false
            case .like(let current):
                //Needed to make the LikeNotificationCellViewModel conform to the Equatable protocol
                return current == viewModel
            }
        }) else {return}
        
        openPost(index: index, username: viewModel.username)
    }
    
    func commentNotificationTableViewCell(_ cell: CommentNotificationTableViewCell, didTapPostWith viewModel: CommentNotificationCellViewModel) {
        guard let index = viewModels.firstIndex(where: {
            switch $0 {
            case .like, .follow:
                return false
            case .comment(let current):
                //Needed to make the LikeNotificationCellViewModel conform to the Equatable protocol
                return current == viewModel
            }
        }) else {return}
        
        openPost(index: index, username: viewModel.username)
        
        
    }
    
    private func openPost(index: Int, username: String) {
        //Makes sure index isnt out of bounds
        guard index < models.count else {return}
        
        let model = models[index]
        let username = username
        guard let postID = model.postId else {return}
        
        //Find post by id from particular user
        DatabaseManager.shared.getPost(with: postID, from: username) { [weak self] post in
            DispatchQueue.main.async {
                guard let post = post else {
                    let alert = UIAlertController(title: "Oops", message: "We are unable to open this post.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                    return
                }
                
                let vc = PostViewController(with: post, username: username)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
    }
}

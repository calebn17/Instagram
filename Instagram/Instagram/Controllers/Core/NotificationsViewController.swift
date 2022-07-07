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
//        NotificationsManager.shared.getNotifications { notifications in
//
//        }
        mockData()
        
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
                        postURL:postURL
                    )
                 ),
            .comment(
                viewModel:
                    CommentNotificationCellViewModel(
                        username: "jeffbezos",
                        profilePictureURL: iconURL,
                        postURL: postURL
                    )
            ),
            .follow(
                viewModel:
                    FollowNotificationCellViewModel(
                        username: "zuckerberg",
                        profilePictureURL: iconURL,
                        isCurrentUserFollowing: true
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
            return cell
            
        case .like(viewModel: let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LikeNotificationTableViewCell.identifier, for: indexPath)
                    as? LikeNotificationTableViewCell
            else {return UITableViewCell()}
            cell.configure(with: viewModel)
            return cell
            
        case .comment(viewModel: let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentNotificationTableViewCell.identifier, for: indexPath)
                    as? CommentNotificationTableViewCell
            else {return UITableViewCell()}
            cell.configure(with: viewModel)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

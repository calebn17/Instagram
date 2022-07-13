//
//  ListViewController.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/27/22.
//

import UIKit

final class ListViewController: UIViewController {
    
//MARK: - Properties
    
    enum ListType {
        case followers(user: User)
        case following(user: User)
        case likers(usernames: [String])
        
        var title: String {
            switch self {
            case .followers: return "Followers"
            case .following: return "Following"
            case .likers: return "Liked By"
            }
        }
    }
    
    let type: ListType
    private var viewModels = [ListUserTableViewCellViewModel]()

//MARK: - SubViews
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(ListUserTableViewCell.self, forCellReuseIdentifier: ListUserTableViewCell.identifier)
        return tableView
    }()
    
//MARK: - Init
    
    init(type: ListType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = type.title
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        configureViewModels()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func configureViewModels() {
        switch type {
        case .followers(user: let targetUser):
            DatabaseManager.shared.followers(for: targetUser.username) {[weak self] usernames in
                self?.viewModels = usernames.compactMap({ ListUserTableViewCellViewModel(imageURL: nil, username: $0) })
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
            
        case .following(user: let targetUser):
            DatabaseManager.shared.following(for: targetUser.username) {[weak self] usernames in
                self?.viewModels = usernames.compactMap({ ListUserTableViewCellViewModel(imageURL: nil, username: $0) })
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
            
        case .likers(usernames: let usernames):
            viewModels = usernames.compactMap({ ListUserTableViewCellViewModel(imageURL: nil, username: $0) })
            tableView.reloadData()
        }
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListUserTableViewCell.identifier, for: indexPath) as? ListUserTableViewCell
        else {return UITableViewCell()}
        
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let username = viewModels[indexPath.row].username
        DatabaseManager.shared.findUser(username: username) { [weak self] user in
            if let user = user {
                DispatchQueue.main.async {
                    let vc = ProfileViewController(user: user)
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}

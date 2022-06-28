//
//  ProfileViewController.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/27/22.
//

import UIKit

class ProfileViewController: UIViewController {

//MARK: - Properties
    
    private let user: User
    private var isCurrentUser: Bool {
        return user.username.lowercased() == UserDefaults.standard.string(forKey: "username")?.lowercased()
    }
    
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
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

//MARK: - Configure
    
    private func configure() {
        if isCurrentUser{
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSettings))
        }
    }

//MARK: - Actions
    
    @objc private func didTapSettings() {
        let vc = SettingsViewController()
        present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }

}

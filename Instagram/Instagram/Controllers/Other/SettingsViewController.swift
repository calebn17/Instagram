//
//  SettingsViewController.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/27/22.
//

import UIKit

class SettingsViewController: UIViewController {
    
//MARK: - Subviews
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()

//MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        configureNavBar()
        configureTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
//MARK: - Configure
    
    private func configureNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        configureTableFooter()
    }
    
    private func configureTableFooter() {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 50))
        let button = UIButton(frame: footer.bounds)
        button.setTitle("Sign Out", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(didTapSignOut), for: .touchUpInside)
        footer.addSubview(button)
        tableView.tableFooterView = footer
    }
    
//MARK: - Actions
    
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapSignOut() {
        let sheet = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { [weak self] _ in
            AuthManager.shared.signOut { success in
                if success {
                    DispatchQueue.main.async {
                        let vc = SignInViewController()
                        let navVC = UINavigationController(rootViewController: vc)
                        navVC.modalPresentationStyle = .fullScreen
                        self?.present(navVC, animated: true, completion: nil)
                    }
                }
                else {
                    
                }
            }
        }))
        present(sheet, animated: true, completion: nil)
    }
}

extension SettingsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

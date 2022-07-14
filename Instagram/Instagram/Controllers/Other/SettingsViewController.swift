//
//  SettingsViewController.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/27/22.
//

import UIKit
import SafariServices

class SettingsViewController: UIViewController {
    
//MARK: - Properties
    private var sections: [SettingsSection] = []
    
//MARK: - Subviews
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()

//MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        configureModels()
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
    
    private func configureModels() {
        sections.append(
            SettingsSection(
                title: "App",
                options: [
                    SettingOption(
                        title: "Rate App",
                        image: UIImage(systemName: "star"),
                        color: .systemOrange) {
                            guard let url = URL(string: "https://apps.apple.com/us/app/instagram/id389801252") else {return}
                            DispatchQueue.main.async {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        },
                    SettingOption(
                        title: "Share App",
                        image: UIImage(systemName: "square.and.arrow.up"),
                        color: .systemBlue) {[weak self] in
                            guard let url = URL(string: "https://apps.apple.com/us/app/instagram/id389801252") else {return}
                            DispatchQueue.main.async {
                                let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
                                self?.present(vc, animated: true)
                            }
                        }
                ]
            )
        )
        sections.append(
            SettingsSection(
                title: "Information",
                options: [
                    SettingOption(
                        title: "Terms of Service",
                        image: UIImage(systemName: "doc"),
                        color: .systemPink) {[weak self] in
                            guard let url = URL(string: "https://www.instagram.com/about/legal/terms/before-january-19-2013/") else {return}
                            DispatchQueue.main.async {
                                let vc = SFSafariViewController(url: url)
                                self?.present(vc, animated: true)
                            }
                        },
                    SettingOption(
                        title: "Privacy Policy",
                        image: UIImage(systemName: "hand.raised"),
                        color: .systemGreen) {[weak self] in
                            guard let url = URL(string: "https://privacycenter.instagram.com/policy/?entry_point=ig_help_center_data_policy_redirect") else {return}
                            DispatchQueue.main.async {
                                let vc = SFSafariViewController(url: url)
                                self?.present(vc, animated: true)
                            }
                        },
                    SettingOption(
                        title: "Get Help",
                        image: UIImage(systemName: "message"),
                        color: .systemPurple) {[weak self] in
                            guard let url = URL(string: "https://help.instagram.com/") else {return}
                            DispatchQueue.main.async {
                                let vc = SFSafariViewController(url: url)
                                self?.present(vc, animated: true)
                            }
                        }
                ]
            )
        )
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

//MARK: - TableView Methods
extension SettingsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section].options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.title
        cell.imageView?.image = model.image
        cell.imageView?.tintColor = model.color
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = sections[indexPath.section].options[indexPath.row]
        model.handler()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}

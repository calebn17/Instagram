//
//  TabBarViewController.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/27/22.
//

import UIKit

final class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let username = UserDefaults.standard.string(forKey: "username"),
              let email = UserDefaults.standard.string(forKey: "email")
        else {return}
        
        let currentUser = User(
            username: username,
            email: email
        )
        
        //Define VCs
        let home = HomeViewController()
        let explore = ExploreViewController()
        let camera = CameraViewController()
        let activity = NotificationsViewController()
        let profile = ProfileViewController(user: currentUser)
        
        let nav1 = UINavigationController(rootViewController: home)
        let nav2 = UINavigationController(rootViewController: explore)
        let nav3 = UINavigationController(rootViewController: camera)
        let nav4 = UINavigationController(rootViewController: activity)
        let nav5 = UINavigationController(rootViewController: profile)
        
        nav1.navigationBar.tintColor = .label
        nav2.navigationBar.tintColor = .label
        nav3.navigationBar.tintColor = .label
        nav4.navigationBar.tintColor = .label
        nav5.navigationBar.tintColor = .label
        
        nav3.navigationItem.backButtonDisplayMode = .minimal
        
        //Define tab items
        nav1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        nav3.tabBarItem = UITabBarItem(title: "Camera", image: UIImage(systemName: "camera"), tag: 1)
        nav4.tabBarItem = UITabBarItem(title: "Notification", image: UIImage(systemName: "bell"), tag: 1)
        nav5.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.circle"), tag: 1)
        
        //Set controllers
        self.setViewControllers([nav1, nav2, nav3, nav4, nav5], animated: false)
       
        UITabBar.appearance().barTintColor = .systemBackground
        UITabBar.appearance().tintColor = .label
    }
}

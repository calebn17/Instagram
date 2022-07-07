//
//  ExploreViewController.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/27/22.
//

import UIKit
import CoreData

final class ExploreViewController: UIViewController {
    
//MARK: - Properties
    
    private let searchVC = UISearchController(searchResultsController: SearchResultsViewController())
    private var posts = [Post]()
    
//MARK: - Subviews
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { index, _ in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.5),
                    heightDimension: .fractionalHeight(1)
                )
            )
            let fullItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
            )
            let tripletItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.33),
                    heightDimension: .fractionalHeight(1)
                )
            )
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.5),
                    heightDimension: .fractionalHeight(1)
                ),
                subitem: fullItem,
                count: 2
            )
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(160)
                ),
                subitems: [item, verticalGroup]
            )
            let threeItemGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(160)
                ),
                subitem: tripletItem,
                count: 3
            )
            let finalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(320)
                ),
                subitems: [horizontalGroup, threeItemGroup]
            )
            return NSCollectionLayoutSection(group: finalGroup)
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        return collectionView
    }()

//MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Explore"
        view.backgroundColor = .systemBackground
        searchVC.searchBar.placeholder = "Search..."
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

//MARK: - API
    private func fetchData() {
        DatabaseManager.shared.explorePosts {[weak self] posts in
            DispatchQueue.main.async {
                self?.posts = posts
                self?.collectionView.reloadData()
            }
        }
    }
}

//MARK: - SearchResultsUpdating
extension ExploreViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let resultsVC = searchController.searchResultsController as? SearchResultsViewController,
              let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty
        else {return}
        
        resultsVC.delegate = self
        
        DatabaseManager.shared.findUsers(with: query) { results in
            DispatchQueue.main.async {
                resultsVC.update(with: results)
            }
        }
    }
}

//MARK: - SearchResults VC
extension ExploreViewController: SearchResultsViewControllerDelegate {
    func searchResultsViewController(_ vc: SearchResultsViewController, didSelectResultsWith user: User) {
        let vc = ProfileViewController(user: user)
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - Collection View
extension ExploreViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath)
                as? PhotoCollectionViewCell
        else {return UICollectionViewCell()}
        
        let model = posts[indexPath.row]
        cell.configure(with: URL(string: model.postURLString))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let post = posts[indexPath.row]
        let vc = PostViewController(with: post)
        navigationController?.pushViewController(vc, animated: true)
    }
}

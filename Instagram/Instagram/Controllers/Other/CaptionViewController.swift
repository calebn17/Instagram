//
//  CaptionViewController.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/27/22.
//

import UIKit

class CaptionViewController: UIViewController {

//MARK: - Properties
    
    private struct constants {
        static let textViewPlaceholder = "Add caption..."
    }
    
    private let image: UIImage
    
//MARK: - SubViews
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.text = constants.textViewPlaceholder
        textView.backgroundColor = .secondarySystemBackground
        textView.textContainerInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        textView.font = .systemFont(ofSize: 22)
        return textView
    }()
    
//MARK: - Init
    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        imageView.image = image
        view.addSubview(textView)
        textView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(didTapPost))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let size: CGFloat = view.width/4
        imageView.frame = CGRect(
            x: (view.width - size)/2,
            y: view.safeAreaInsets.top + 10,
            width: size,
            height: size
        )
        textView.frame = CGRect(
            x: 20,
            y: imageView.bottom + 20,
            width: view.width - 40,
            height: 100
        )
    }

//MARK: - Actions
    
    @objc private func didTapPost() {
        textView.resignFirstResponder()
        var caption = textView.text ?? ""
        if caption == constants.textViewPlaceholder {
            caption = ""
        }
        
        //Generate post ID
        guard let newPostID = createNewPostID(),
              let stringDate = String.date(from: Date())
        else {return}
        
        //Upload Post
        StorageManager.shared.uploadPost(data: image.pngData(), id: newPostID) { success in
            guard success else {
                print("error: failed to upload")
                return
            }
            //New Post
            let newPost = Post(
                id: newPostID,
                caption: caption,
                postedDate: stringDate,
                likers: []
            )
            //Update Database
            DatabaseManager.shared.createPost(newPost: newPost) {[weak self] finished in
                guard finished else {return}
                DispatchQueue.main.async {
                    self?.tabBarController?.tabBar.isHidden = false
                    self?.tabBarController?.selectedIndex = 0
                    self?.navigationController?.popToRootViewController(animated: false)
                }
            }
        }
        
        
        
    }
    
    private func createNewPostID() -> String? {
        let timeStamp = Date().timeIntervalSince1970
        let randomNumber = Int.random(in: 0...1000)
        guard let username = UserDefaults.standard.string(forKey: "username") else {return nil}
        return "\(username)_\(randomNumber)_\(timeStamp)"
    }
}

//MARK: - TextView Methods
extension CaptionViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == constants.textViewPlaceholder {
            textView.text = nil
        }
    }
}

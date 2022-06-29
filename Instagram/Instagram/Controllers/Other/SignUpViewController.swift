//
//  SignUpViewController.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/27/22.
//

import UIKit
import SafariServices

final class SignUpViewController: UIViewController {
    
    public var completion: (() -> Void)?

//MARK: - SubViews
    private let profilePictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .lightGray
        imageView.image = UIImage(systemName: "person.circle")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 45
        return imageView
    }()
    
    private let usernameField: IGTextField = {
        let field = IGTextField()
        field.placeholder = "Username"
        field.returnKeyType = .next
        field.autocorrectionType = .no
        return field
    }()
    
    private let emailField: IGTextField = {
        let field = IGTextField()
        field.placeholder = "Email Address"
        field.keyboardType = .emailAddress
        field.returnKeyType = .next
        field.autocorrectionType = .no
        return field
    }()
    
    private let passwordField: IGTextField = {
        let field = IGTextField()
        field.placeholder = "Create Password"
        field.isSecureTextEntry = true
        field.keyboardType = .default
        field.returnKeyType = .continue
        field.autocorrectionType = .no
        return field
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    private let termsButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        button.setTitle("Terms of Service", for: .normal)
        return button
    }()
    
    private let privacyButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        button.setTitle("Privacy Policy", for: .normal)
        return button
    }()

//MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Account"
        view.backgroundColor = .systemBackground
        addSubviews()
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        addButtonActions()
        addImageGesture()
    }
       
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureSubviewFrames()
    }
    
//MARK: - Configure
    
    private func addSubviews() {
        view.addSubview(profilePictureImageView)
        view.addSubview(usernameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signUpButton)
        view.addSubview(termsButton)
        view.addSubview(privacyButton)
    }
    
    private func configureSubviewFrames() {
        
        let imageSize: CGFloat = 90
        
        profilePictureImageView.frame = CGRect(
            x: (view.width - imageSize)/2,
            y: view.safeAreaInsets.top + 15,
            width: imageSize,
            height: imageSize
        )
        usernameField.frame = CGRect(
            x: 25,
            y: profilePictureImageView.bottom + 40,
            width: view.width - 50,
            height: 50
        )
        emailField.frame = CGRect(
            x: 25,
            y: usernameField.bottom + 20,
            width: view.width - 50,
            height: 50
        )
        passwordField.frame = CGRect(
            x: 25,
            y: emailField.bottom + 20,
            width: view.width - 50,
            height: 50
        )
        signUpButton.frame = CGRect(
            x: 35,
            y: passwordField.bottom + 30,
            width: view.width - 70,
            height: 50
        )
       
        termsButton.frame = CGRect(
            x: 35,
            y: signUpButton.bottom + 30,
            width: view.width - 70,
            height: 30
        )
        privacyButton.frame = CGRect(
            x: 35,
            y: termsButton.bottom,
            width: view.width - 70,
            height: 30
        )
    }
    
    private func addButtonActions() {
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(didTapTerms), for: .touchUpInside)
        privacyButton.addTarget(self, action: #selector(didTapPrivacy), for: .touchUpInside)
    }
    
    private func addImageGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        profilePictureImageView.isUserInteractionEnabled = true
        profilePictureImageView.addGestureRecognizer(tap)
    }

//MARK: - Actions
    
    
    @objc private func didTapSignUp() {
        usernameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let username = usernameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !username.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.isEmpty,
              username.count >= 3,
              password.count >= 6,
              username.trimmingCharacters(in: .alphanumerics).isEmpty //validate that username is only using alphanumerics
        else {
            presentError()
            return
        }
        
        //converting picture to a data type
        let data = profilePictureImageView.image?.pngData()
        AuthManager.shared.signUp(email: email, username: username, password: password, profilePicture: data) { [weak self] result in
            switch result {
            case .success(let user):
                UserDefaults.standard.set(user.email, forKey: "email")
                UserDefaults.standard.set(user.username, forKey: "username")
                //the root controller in this case is the Signedin screen (defined in SceneDelegate)
                self?.navigationController?.popToRootViewController(animated: true)
                self?.completion?()
            case .failure(let error):
                print("Sign Up Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func presentError() {
        let alert = UIAlertController(
            title: "Oops",
            message: "Please make sure to fil all fields and have a password longer than 6 characters",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func didTapTerms() {
        guard let url = URL(string: "https://www.instagram.com") else {return}
        
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
        
    }
    
    @objc private func didTapPrivacy() {
        guard let url = URL(string: "https://www.instagram.com") else {return}
        
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    
    @objc private func didTapImage() {
        let sheet = UIAlertController(title: "Profile Picture", message: "Set a profile picture", preferredStyle: .actionSheet)
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

//MARK: - UITextField Methods

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            emailField.resignFirstResponder()
        }
        else if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            didTapSignUp()
        }
        return true
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {return}
        profilePictureImageView.image = image
    }
}

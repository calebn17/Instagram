//
//  SignInViewController.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/27/22.
//

import UIKit
import SafariServices

final class SignInViewController: UIViewController {

//MARK: - SubViews
    private let headerView = SignInHeaderView()
    
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
        field.placeholder = "Password"
        field.isSecureTextEntry = true
        field.keyboardType = .default
        field.returnKeyType = .continue
        field.autocorrectionType = .no
        return field
    }()
    
    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    private let createAccountButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        button.setTitle("Create Account", for: .normal)
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

//MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign In"
        view.backgroundColor = .systemBackground
        addSubviews()
        
        emailField.delegate = self
        passwordField.delegate = self
        
        addButtonActions()
    }
       
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureSubviewFrames()
    }
    
//MARK: - Configure
    
    private func addSubviews() {
        view.addSubview(headerView)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signInButton)
        view.addSubview(createAccountButton)
        view.addSubview(termsButton)
        view.addSubview(privacyButton)
    }
    
    private func configureSubviewFrames() {
        headerView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.width,
            height: (view.height - view.safeAreaInsets.top)/3
        )
        emailField.frame = CGRect(
            x: 25,
            y: headerView.bottom + 40,
            width: view.width - 50,
            height: 50
        )
        passwordField.frame = CGRect(
            x: 25,
            y: emailField.bottom + 20,
            width: view.width - 50,
            height: 50
        )
        signInButton.frame = CGRect(
            x: 35,
            y: passwordField.bottom + 30,
            width: view.width - 70,
            height: 50
        )
        createAccountButton.frame = CGRect(
            x: 35,
            y: signInButton.bottom + 30,
            width: view.width - 70,
            height: 50
        )
        termsButton.frame = CGRect(
            x: 35,
            y: createAccountButton.bottom + 30,
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
        signInButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(didTapTerms), for: .touchUpInside)
        privacyButton.addTarget(self, action: #selector(didTapPrivacy), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(didTapCreateAccount), for: .touchUpInside)
    }

//MARK: - Actions
    
    
    @objc private func signIn() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text,
              let password = passwordField.text,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.isEmpty,
              password.count >= 6 else
              {return}
        
        AuthManager.shared.signIn(email: email, password: password) {[weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    let tabVC = TabBarViewController()
                    tabVC.modalPresentationStyle = .fullScreen
                    self?.present(tabVC, animated: true, completion: nil)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
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
    
    @objc private func didTapCreateAccount() {
        let vc = SignUpViewController()
        vc.completion = {
            DispatchQueue.main.async {[weak self] in
                //root controller in this case is the SignedIn screen so we need to present the tabbar VC
                let tabVC = TabBarViewController()
                tabVC.modalPresentationStyle = .fullScreen
                self?.present(tabVC, animated: true, completion: nil)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

//MARK: - UITextField Methods

extension SignInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            signIn()
        }
        return true
    }
}

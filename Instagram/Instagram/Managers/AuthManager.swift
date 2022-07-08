//
//  AuthManager.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/27/22.
//
import FirebaseAuth
import Foundation

class AuthManager {
    
    static let shared = AuthManager()
    private init() {}
    let auth = Auth.auth()
    
    enum AuthError: Error {
        case newUserCreation
        case signInFailed
    }
    
    public var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    public func signUp(email: String, username: String, password: String, profilePicture: Data?, completion: @escaping (Result<User, Error>) -> Void) {
        
        let newUser: User = User(username: username, email: email)
        
        auth.createUser(withEmail: email, password: password) { result, error in
            guard result != nil, error == nil else {
                completion(.failure(AuthError.newUserCreation))
                return
            }
            DatabaseManager.shared.createUser(newUser: newUser) { success in
                if success {
                    StorageManager.shared.uploadProfilePicture(username: username, data: profilePicture) { uploadSuccess in
                        if uploadSuccess {
                            completion(.success(newUser))
                        }
                        else {
                            completion(.failure(AuthError.newUserCreation))
                        }
                    }
                }
                else {
                    completion(.failure(AuthError.newUserCreation))
                }
            }
        }
    }
    
    public func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        //Checking to see if this user exists
        //if it does then return that user as a User object
        //then sign in
        DatabaseManager.shared.findUser(email: email) { [weak self] user in
            guard let user = user else {
                completion(.failure(AuthError.signInFailed))
                return
            }
            self?.auth.signIn(withEmail: email, password: password) { result, error in
                guard result != nil,
                      error == nil else {
                          completion(.failure(AuthError.signInFailed))
                          return
                      }
                UserDefaults.standard.set(user.username, forKey: "username")
                UserDefaults.standard.set(user.email, forKey: "email")
                completion(.success(user))
            }
        }
    }
    
    public func signOut(completion: @escaping (Bool) -> Void) {
        
        do {
            try auth.signOut()
            completion(true)
        }
        catch {
            completion(false)
        }
    }
    
}

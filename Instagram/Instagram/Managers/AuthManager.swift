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
    
    public var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    public func signUp(email: String, username: String, password: String, profilePicture: Data?, completion: @escaping (Result<UserModel, Error>) -> Void) {
        
    }
    
    public func signIn(email: String, password: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
        
    }
    
    public func signOut(completion: @escaping (Bool) -> Void) {
        
    }
    
}

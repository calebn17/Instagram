//
//  DatabaseManager.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/27/22.
//

import Foundation
import FirebaseFirestore

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    private init() {}
    let database = Firestore.firestore()
    
    public func createUser(newUser: User, completion: @escaping (Bool) -> Void) {
        
        let ref = database.document("users/\(newUser.username)")
        guard let data = newUser.asDictionary() else {
            completion(false)
            return
        }
        ref.setData(data) { error in
            completion(error == nil)
        }
    }
    
    public func findUser(with email: String, completion: @escaping (User?) -> Void) {
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }),
                  error == nil
            else {
                completion(nil)
                return
            }
            let user = users.first(where: {$0.email == email})
            completion(user)
        }
    }
}

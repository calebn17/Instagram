//
//  StorageManager.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/27/22.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    private init() {}
    let storage = Storage.storage().reference()
    
    public func uploadProfilePicture(username: String, data: Data?, completion: @escaping (Bool) -> Void) {
        guard let data = data else {
            completion(false)
            return
        }
        storage.child("\(username)/profile_picture.png").putData(data, metadata: nil) { _, error in
            completion(error == nil)
        }
    }
    
    public func uploadPost(data: Data?, id: String, completion: @escaping (Bool) -> Void) {
        guard let data = data,
              let username = UserDefaults.standard.string(forKey: "username")
        else {
            completion(false)
            return
        }
        storage.child("\(username)/posts/\(id).png").putData(data, metadata: nil) { _, error in
            completion(error == nil)
        }
    }
    
    public func downloadURL(for post: Post, completion: @escaping (URL?) -> Void) {
        guard let ref = post.storageReference else {return}
        storage.child(ref).downloadURL { url, _ in
            completion(url)
        }
    }
}

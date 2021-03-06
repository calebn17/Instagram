//
//  PostModel.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/27/22.
//

import Foundation

struct Post: Codable {
    let id: String
    let caption: String
    let postedDate: String
    let postURLString: String
    var likers: [String]
    
    var date: Date {
        return DateFormatter.formatter.date(from: postedDate) ?? Date()
    }
    
    var storageReference: String? {
        guard let username = UserDefaults.standard.string(forKey: "username") else {return nil}
        return "\(username)/posts/\(id).png"
    }
}

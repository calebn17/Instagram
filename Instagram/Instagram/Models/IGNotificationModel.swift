//
//  Notification.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/27/22.
//

import Foundation

struct IGNotification: Codable {
    let identifier: String
    let notificationType: Int //1: like, 2: comment, 3: follow
    let profilePictureURLString: String
    let username: String
    let dateString: String
    
    //Follow or Unfollow
    let isFollowing: Bool?
    
    //Like or Comment
    let postId: String?
    let postURLString: String?
    
}

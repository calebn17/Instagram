//
//  NotificationCellViewModels.swift
//  Instagram
//
//  Created by Caleb Ngai on 7/7/22.
//

import Foundation

struct LikeNotificationCellViewModel: Equatable {
    let username: String
    let profilePictureURL: URL
    let postURL: URL
    let date: String
}

struct FollowNotificationCellViewModel: Equatable {
    let username: String
    let profilePictureURL: URL
    let isCurrentUserFollowing: Bool
    let date: String
}

struct CommentNotificationCellViewModel: Equatable {
    let username: String
    let profilePictureURL: URL
    let postURL: URL
    let date: String
}

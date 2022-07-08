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
}

struct FollowNotificationCellViewModel {
    let username: String
    let profilePictureURL: URL
    let isCurrentUserFollowing: Bool
}

struct CommentNotificationCellViewModel {
    let username: String
    let profilePictureURL: URL
    let postURL: URL
}

//
//  NotificationCellType.swift
//  Instagram
//
//  Created by Caleb Ngai on 7/7/22.
//

import Foundation

enum NotificationCellType {
    case follow(viewModel: FollowNotificationCellViewModel)
    case like(viewModel: LikeNotificationCellViewModel)
    case comment(viewModel: CommentNotificationCellViewModel)
}

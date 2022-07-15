//
//  StoriesViewModel.swift
//  Instagram
//
//  Created by Caleb Ngai on 7/15/22.
//

import Foundation
import UIKit

struct StoriesViewModel {
    let stories: [Story]
}

struct Story {
    let username: String
    let image: UIImage?
}

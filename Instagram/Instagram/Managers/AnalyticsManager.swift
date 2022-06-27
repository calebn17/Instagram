//
//  AnalyticsManager.swift
//  Instagram
//
//  Created by Caleb Ngai on 6/27/22.
//

import Foundation
import FirebaseAnalytics

final class AnalyticsManager {
    
    static let shared = AnalyticsManager()
    private init() {}
    
    
    func logEvent() {
        Analytics.logEvent("", parameters: [:])
    }
}

    

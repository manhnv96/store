//
//  HomeRefreshEnvironment.swift
//  Store
//
//  Environment key for triggering home view refresh
//

import SwiftUI

// MARK: - Environment Key for Home Refresh

struct HomeRefreshTriggerKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var triggerHomeRefresh: () -> Void {
        get { self[HomeRefreshTriggerKey.self] }
        set { self[HomeRefreshTriggerKey.self] = newValue }
    }
}

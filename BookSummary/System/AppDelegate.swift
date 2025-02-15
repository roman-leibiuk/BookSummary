//
//  AppDelegate.swift
//  BookSummary
//
//  Created by Roman Leibiuk on 15.02.2025.
//

import SwiftUI
import ComposableArchitecture

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        store.send(.appDelegate(.didFinishLaunching))
        return true
    }
}

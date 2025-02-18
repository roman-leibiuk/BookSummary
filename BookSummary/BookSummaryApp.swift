//
//  BookSummaryApp.swift
//  BookSummary
//
//  Created by Roman Leibiuk on 15.02.2025.
//

import SwiftUI

@main
struct BookSummaryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            AppView(store: self.appDelegate.store)
        }
    }
}

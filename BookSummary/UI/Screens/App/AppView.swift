//
//  AppView.swift
//  BookSummary
//
//  Created by Roman Leibiuk on 15.02.2025.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>
    
    var body: some View {
        content
    }
}

private extension AppView {
    @ViewBuilder
    var content: some View {
        switch store.state {
        case .summaryPlayer:
            summaryPlayer
        }
    }
    
    @ViewBuilder
    var summaryPlayer: some View {
        if let store = store.scope(
            state: \.summaryPlayer,
            action: \.summaryPlayerAction
        ) {
            SummaryPlayerView(store: store)
                .transition(.slide)
        }
    }
}

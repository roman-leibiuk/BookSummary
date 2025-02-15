//
//  SummaryPlayerView.swift
//  BookSummary
//
//  Created by Roman Leibiuk on 15.02.2025.
//

import SwiftUI
import ComposableArchitecture

struct SummaryPlayerView: View {
    @Bindable var store: StoreOf<SummaryPlayerFeature>
    
    var body: some View {
        content
    }
}

private extension SummaryPlayerView {
    var content: some View {
        VStack {
            Text("Hello World")
            audioPlayer
        }
    }
    
    var audioPlayer: some View {
        AudioPlayerView(
            store: store.scope(
                state: \.audioPlayerState,
                action: \.audioPlayerAction
            )
        )
    }
}

#Preview {
    SummaryPlayerView(store: .init(initialState: SummaryPlayerFeature.State(), reducer: {
        SummaryPlayerFeature()
    }))
}

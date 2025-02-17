//
//  SummaryPlayerView.swift
//  BookSummary
//
//  Created by Roman Leibiuk on 15.02.2025.
//

import SwiftUI
import ComposableArchitecture

struct SummaryPlayerView: View {
    let store: StoreOf<SummaryPlayerFeature>
    
    var body: some View {
        content
            .onAppear {
                store.send(.view(.onAppear))
            }
    }
}

private extension SummaryPlayerView {
    var content: some View {
        VStack(spacing: Spacing.xl) {
            image
            textStack
            audioPlayer
            Spacer()
        }
        .padding(.top, Spacing.xl)
        .padding(.horizontal, Spacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.appBackground)
    }
    
    var audioPlayer: some View {
        AudioPlayerView(
            store: store.scope(
                state: \.audioPlayerState,
                action: \.audioPlayerAction
            )
        )
    }
    
    var image: some View {
        AsyncImage(url: store.currentChapter?.imageUrl) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            ZStack {
                Rectangle().fill(.appSwitchBackGround)
                ProgressView()
            }
        }
        .frame(
            width: UIScreen.main.bounds.width / 1.9,
            height: UIScreen.main.bounds.height / 2.6
        )
        .clipped()
    }
    
    var keyPoint: some View {
        Text(store.keyPoint)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.appGreyText)
    }
    
    @ViewBuilder
    var title: some View {
        if let title = store.currentChapter?.title {
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.black)
        }
    }
    
    var textStack: some View {
        VStack(spacing: Spacing.sm) {
            keyPoint
            title
        }
    }
}

#Preview {
    SummaryPlayerView(store: .init(initialState: SummaryPlayerFeature.State(), reducer: {
        SummaryPlayerFeature()
    }))
}

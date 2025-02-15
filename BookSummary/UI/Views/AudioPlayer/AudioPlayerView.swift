//
//  AudioPlayerView.swift
//  BookSummary
//
//  Created by Roman Leibiuk on 15.02.2025.
//

import SwiftUI
import ComposableArchitecture

struct AudioPlayerView: View {
    @Bindable var store: StoreOf<AudioPlayerFeature>
    
    var body: some View {
        content
    }
}

private extension AudioPlayerView {
    var content: some View {
        VStack {
            Text("test")
            controller
        }
        .background(.clear)
    }
    
    var controller: some View {
        HStack(spacing: Spacing.lg) {
            button(iconName: Constants.backward) { store.send(.onBackward) }
            button(iconName: Constants.rewind) { store.send(.onRewind) }
            button(iconName: Constants.playIcon) { store.send(.onPlayPause) }
            button(iconName: Constants.fastForward) { store.send(.onFastForward) }
            button(iconName: Constants.forward) { store.send(.onForward) }
        }
        .frame(height: Constants.buttonSize)
        .padding(.horizontal, Spacing.xl)
    }
    
    func button(
        iconName: String,
        action: @escaping () -> Void
    ) -> some  View {
        Button(
            action: action,
            label: {
                Image(systemName: iconName)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(.black)
//                    .frame(width: Constants.buttonSize, height: Constants.buttonSize)
            }
        )
    }
}

#Preview {
    AudioPlayerView(store: .init(initialState: AudioPlayerFeature.State(), reducer: {
        AudioPlayerFeature()
    }))
}

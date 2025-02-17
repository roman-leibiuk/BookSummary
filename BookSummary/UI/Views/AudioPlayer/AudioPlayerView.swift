//
//  AudioPlayerView.swift
//  BookSummary
//
//  Created by Roman Leibiuk on 15.02.2025.
//

import SwiftUI
import ComposableArchitecture

struct AudioPlayerView: View {
    let store: StoreOf<AudioPlayerFeature>
    
    var body: some View {
        content
    }
}

private extension AudioPlayerView {
    var content: some View {
        VStack {
            Text("Inner View")
            timeLine
            controller
        }
    }
    
    var timeLine: some View {
        VStack {
            AudioTimeLineView(
                currentTime: store.currentTime,
                totalTime: store.totalTime
            ) {
                store.send(.view(.seekToTime($0)))
            }
        }
    }
    
    var controller: some View {
        HStack(spacing: Spacing.lg) {
            button(iconName: Constants.backward, size: Spacing.lg, isDisable: !store.hasPreviosTrack) { store.send(.view(.onBackward)) }
            button(iconName: Constants.rewind) { store.send(.view(.onRewind)) }
            button(
                iconName: store.state.isPlaying ? Constants.pauseIcon : Constants.playIcon
            ) {
                store.send(.view(.onPlayPause))
            }
            button(iconName: Constants.fastForward) { store.send(.view(.onFastForward)) }
            button(iconName: Constants.forward, size: Spacing.lg, isDisable: !store.hasNextTrack) { store.send(.view(.onForward)) }
        }
        .padding(.horizontal, Spacing.xl)
    }
    
    func button(
        iconName: String,
        size: CGFloat = Spacing.xl,
        isDisable: Bool = false,
        action: @escaping () -> Void
    ) -> some  View {
        Button(
            action: action,
            label: {
                Image(systemName: iconName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(isDisable ? .appGreyProgress : .black)
                    .frame(width: size, height: size)
                    .animation(nil, value: store.isPlaying)
            }
        )
        .disabled(isDisable)
    }
}

#Preview {
    AudioPlayerView(store: .init(initialState: AudioPlayerFeature.State(), reducer: {
        AudioPlayerFeature()
    }))
}

//
//  AudioPlayerView.swift
//  BookSummary
//
//  Created by Roman Leibiuk on 15.02.2025.
//

import SwiftUI
import ComposableArchitecture

struct AudioPlayerView: View {
    @Environment(\.scenePhase) var scenePhase
    let store: StoreOf<AudioPlayerFeature>
    
    var body: some View {
        content
            .onChange(of: scenePhase, { _, newValue in
                guard newValue == .inactive else { return }
                store.send(.view(.onDisappear))
            })
    }
}

private extension AudioPlayerView {
    var content: some View {
        VStack(spacing: Spacing.lg) {
            timeLine
            VStack(spacing: Spacing.xxl) {
                speed
                controller
            }
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
        HStack(spacing: Spacing.xl) {
            button(
                iconName: Constants.backward,
                size: Spacing.lg,
                isDisable: !store.hasPreviousTrack
            ) {
                store.send(.view(.onBackward))
            }
            button(iconName: Constants.rewind) {
                store.send(.view(.onRewind))
            }
            button(
                iconName: store.state.isPlaying
                ? Constants.pauseIcon
                : Constants.playIcon
            ) {
                store.send(.view(.onPlayPause))
            }
            button(iconName: Constants.fastForward) {
                store.send(.view(.onFastForward))
            }
            button(
                iconName: Constants.forward,
                size: Spacing.lg,
                isDisable: !store.hasNextTrack
            ) {
                store.send(.view(.onForward))
            }
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
    
    var speed: some View {
        Menu(store.speedTitle) {
            ForEach(store.speedOptions.reversed(), id: \.self) { option in
                Button(AudioPlayerFeature.Constant.speedOption(option)) {
                    store.send(.view(.selectSpeed(option)))
                }
            }
        }
        .font(.system(size: 13, weight: .semibold))
        .foregroundStyle(.black)
        .padding(.vertical, Spacing.sm)
        .padding(.horizontal, Spacing.sm)
        .background(.appGreyProgress)
        .clipShape(RoundedRectangle(cornerRadius: Spacing.sm))
    }
}

#Preview {
    AudioPlayerView(store: .init(initialState: AudioPlayerFeature.State(), reducer: {
        AudioPlayerFeature()
    }))
}

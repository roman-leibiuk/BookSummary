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
            .alert($store.scope(state: \.alert, action: \.alert))
    }
}

private extension SummaryPlayerView {
    var content: some View {
        VStack(spacing: Spacing.xl) {
            image
            textStack
            audioPlayer
            Spacer()
            switcher
        }
        .padding(.top, Spacing.xl)
        .padding(.horizontal, Spacing.md)
        .padding(.bottom,Spacing.lg)
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
                Rectangle().fill(.appSwitchBackground)
                ProgressView().tint(.appSecondBlue)
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
    
    var switcher: some View {
        ZStack(alignment: .leading) {
            Circle()
                .fill(.accent)
                .frame(width: Spacing.xxl, height: Spacing.xxl)
                .offset(x: store.switchCircleOffset)
            HStack(spacing: Spacing.xl) {
                switchItem(imageName: Constants.headphonesIcon) {
                    store.send(.view(.onTapSwitch(isList: false)), animation: .default)
                }
                .foregroundStyle(store.switchCircleOffset == .zero ? .white : .black)
                switchItem(imageName: Constants.listIcon) {
                    store.send(.view(.onTapSwitch(isList: true)), animation: .default)
                }
                .foregroundStyle(store.switchCircleOffset != .zero ? .white : .black)
            }
            .padding(.horizontal, Spacing.md)
        }
        .padding(Spacing.xs)
        .background(
            Capsule()
                .fill(.appSwitchBackground)
                .stroke(Color.appGreyProgress, lineWidth: 1)
        )
    }
    
    func switchItem(
        imageName: String,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: imageName)
                .renderingMode(.template)
                .resizable()
                .scaledToFill()
                .frame(width: Spacing.md, height: Spacing.md)
        }
    }
}

#Preview {
    SummaryPlayerView(store: .init(initialState: SummaryPlayerFeature.State(), reducer: {
        SummaryPlayerFeature()
    }))
}

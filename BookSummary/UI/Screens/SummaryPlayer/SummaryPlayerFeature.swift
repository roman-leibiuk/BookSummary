//
//  SummaryPlayerFeature.swift
//  BookSummary
//
//  Created by Roman Leibiuk on 15.02.2025.
//

import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct SummaryPlayerFeature {
    
    @ObservableState
    struct State {
        var audioPlayerState = AudioPlayerFeature.State()
    }
    
    enum Action {
        case audioPlayerAction(AudioPlayerFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.audioPlayerState, action: \.audioPlayerAction) {
            AudioPlayerFeature()
        }
        
        Reduce { state, action in
            switch action {
            case let .audioPlayerAction(playerAction):
                switch playerAction {
                case .onPlayPause:
                    return .none
                case .onBackward:
                    return .none
                case .onForward:
                    return .none
                    
                default:
                    return .none
                }
            }
        }
    }
}

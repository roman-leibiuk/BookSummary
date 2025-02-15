//
//  AudioPlayerFeature.swift
//  BookSummary
//
//  Created by Roman Leibiuk on 15.02.2025.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AudioPlayerFeature {
    
    @ObservableState
    struct State {
        var isPlaying: Bool = false
    }
    
    enum Action {
        case onPlayPause
        case onFastForward
        case onRewind
        case onForward
        case onBackward
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onPlayPause:
                return .none
            case .onFastForward:
                return .none
            case .onRewind:
                return .none
            case .onForward:
                return .none
            case .onBackward:
                return .none
            }
        }
    }
}

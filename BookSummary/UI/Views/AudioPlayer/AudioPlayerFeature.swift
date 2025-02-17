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
        var chapter: ChapterModel?
        var isPlaying: Bool = false
        var hasPreviosTrack: Bool = false
        var hasNextTrack: Bool = false
        var isReadyToPlay: Bool = false
        
        var currentTime: TimeInterval = 0
        var totalTime: TimeInterval = 0
        
        var speed: Float = 1
        var speedTitle: String = "Speed x1"
        var speedOptions: [Float] = [0.5, 1, 1.25, 1.5, 2]
    }
    
    enum Action {
        enum ViewAction {
            case onPlayPause
            case onFastForward
            case onRewind
            case onForward
            case onBackward
            case seekToTime(TimeInterval)
            case selectSpeed(Float)
        }
        
        enum InnerAction {
            case play(ChapterModel?)
            case availableTrack(prev: Bool, next: Bool)
            case pause
            case resume
            case readyToPlay(Bool)
            case setCurrentTime(TimeInterval)
            case setTotalTime(TimeInterval)
            case seekToTime(TimeInterval)
            case updateTime
        }

        enum DelegateAction {
            case onForward
            case onBackward
        }
        
        case view(ViewAction)
        case inner(InnerAction)
        case delegate(DelegateAction)
    }
 
    @Dependency(\.audioPlayerClient) var audioPlayerClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .onPlayPause:
                    guard state.isReadyToPlay else {
                        return .none
                    }
                    return state.isPlaying
                    ? .send(.inner(.pause))
                    : .send(.inner(.resume))
                case .onFastForward:
                    return .none
                case .onRewind:
                    return .none
                case .onForward:
                    return .send(.delegate(.onForward))
                case .onBackward:
                    return .send(.delegate(.onBackward))
                case let .seekToTime(time):
                    return .send(.inner(.seekToTime(time)))
                case let .selectSpeed(option):
                    state.speedTitle = "Speed x\(String(format: "%g", option))"
                    return .run { send in
                        await audioPlayerClient.playbackRate(option)
                    }
                }
                
            case let .inner(innerAction):
                switch innerAction {
                case let .play(chapter):
                    state.chapter = chapter
                    guard let chapter = state.chapter else {
                        return .none
                    }
//                    state.isPlaying = true
                    return .run { send in
                        let actions = await audioPlayerClient.play(chapter)

                        for await action in actions {
                            switch action {
                            case .readyToPlay:
                                print(">>> readyToPlay")
                                await send(.inner(.updateTime))
                                await send(.inner(.readyToPlay(true)))
                            case .didPause:
                                print(">>> didPause")
                            case .didResume:
                                print(">>> didResume")
                            case let .error(error):
                                print(">>> errorOccurred", error.localizedDescription)
                            case .didFinish:
                                await audioPlayerClient.seekTo(0)
                                await send(.inner(.pause))
                            }
                        }
                    }
                    
                case let .readyToPlay(isReady):
                    state.isReadyToPlay = isReady
                    
                    return .none
                    
                case .pause:
                    state.isPlaying = false
                    return .run { @MainActor send in
                        await audioPlayerClient.pause()
                    }
                case .resume:
                    state.isPlaying = true
                    return .run { @MainActor send in
                        await audioPlayerClient.resume()
                    }
                case let .setCurrentTime(time):
                    state.currentTime = time
                    return .none
                case let .setTotalTime(time):
                    state.totalTime = time
                    return .none
                case .updateTime:
                    return .run { send in
                        let totalTime = await audioPlayerClient.totalTime()
                        let times = await audioPlayerClient.elapsedTimeUpdates()
                        await send(.inner(.setTotalTime(totalTime)))
                        
                        for await time in times {
                            await send(.inner(.setCurrentTime(time)))
                        }
                    }
                case let .seekToTime(time):
                    return .run { send in
                        await audioPlayerClient.seekTo(time)
                    }
                case let .availableTrack(prev, next):
                    state.hasPreviosTrack = prev
                    state.hasNextTrack = next
                    return .none
                }
            case .delegate:
                return .none
            }
        }
    }
}

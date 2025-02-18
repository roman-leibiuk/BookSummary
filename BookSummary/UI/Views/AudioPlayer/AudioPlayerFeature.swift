//
//  AudioPlayerFeature.swift
//  BookSummary
//
//  Created by Roman Leibiuk on 15.02.2025.
//

import Foundation
import ComposableArchitecture
import AudioLibrary

@Reducer
struct AudioPlayerFeature {
    enum Constant {
        static var rewindValue: TimeInterval = 5
        static var fastForwardValue: TimeInterval = 10
        static func speedTitle(by option: Float) -> String {
            "Speed x\(String(format: "%g", option))"
        }
        
        static func speedOption(_ option: Float) -> String {
            String(format: "%g", option) + "x"
        }
    }
    
    @ObservableState
    struct State {
        var chapter: ChapterModel?
        var isReadyToPlay: Bool = false
        var isPlaying: Bool = false
        var hasPreviousTrack: Bool = false
        var hasNextTrack: Bool = false
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
            case onDisappear
        }
        
        enum InnerAction {
            case play(ChapterModel?, shouldPlay: Bool)
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
            case errorOccurred(String)
        }
        
        case view(ViewAction)
        case inner(InnerAction)
        case delegate(DelegateAction)
    }
    
    @Dependency(\ .audioPlayerClient) var audioPlayerClient
    
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
                    return .run { _ in
                        await audioPlayerClient.fastForward(Constant.fastForwardValue)
                    }
                    
                case .onRewind:
                    return .run { _ in
                        await audioPlayerClient.rewind(Constant.rewindValue)
                    }
                    
                case .onForward:
                    return .send(.delegate(.onForward))
                    
                case .onBackward:
                    return .send(.delegate(.onBackward))
                    
                case let .seekToTime(time):
                    return .send(.inner(.seekToTime(time)))
                    
                case let .selectSpeed(option):
                    state.speed = option
                    state.speedTitle = Constant.speedTitle(by: option)
                    return .run { _ in
                        await audioPlayerClient.playbackRate(option)
                    }
                    
                case .onDisappear:
                    return .send(.inner(.pause))
                }
                
            case let .inner(innerAction):
                switch innerAction {
                case let .play(chapter, shouldPlay):
                    state.chapter = chapter
                    guard let chapter = state.chapter else {
                        return .none
                    }
                    return .run { send in
                        let actions = await audioPlayerClient.play(chapter)
                        
                        for await action in actions {
                            switch action {
                            case .readyToPlay:
                                await send(.inner(.updateTime))
                                await send(.inner(.readyToPlay(true)))
                                    if shouldPlay { await send(.inner(.resume)) }
                                
                            case .didFinish:
                                await audioPlayerClient.seekTo(.zero)
                                await send(.delegate(.onForward))
                                
                            case let .error(error):
                                await send(.delegate(.errorOccurred(error)))
                            }
                        }
                    }
                    
                case let .readyToPlay(isReady):
                    state.isReadyToPlay = isReady
                    return .none
                    
                case .pause:
                    state.isPlaying = false
                    return .run { _ in
                        await audioPlayerClient.pause()
                    }
                    
                case .resume:
                    state.isPlaying = true
                    let speed = state.speed
                    return .run { send in
                        await audioPlayerClient.resume()
                        await audioPlayerClient.playbackRate(speed)
                    }
                    
                case let .setCurrentTime(time):
                    state.currentTime = time
                    return .none
                    
                case let .setTotalTime(time):
                    state.totalTime = time
                    return .none
                    
                case .updateTime:
                    return .run {  send in
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
                    state.hasPreviousTrack = prev
                    state.hasNextTrack = next
                    return .none
                }
                
            case .delegate:
                return .none
            }
        }
    }
}

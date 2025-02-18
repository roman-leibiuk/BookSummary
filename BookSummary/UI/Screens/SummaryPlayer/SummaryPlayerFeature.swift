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
    enum Constants {
        static func keyPoint(current: Int, total: Int) -> String {
            "KEY POINT \(current) OF \(total)"
        }
    }
    
    @ObservableState
    struct State {
        var book: BookModel?
        var currentChapter: ChapterModel?
        var image: URL?
        var keyPoint: String = ""
        var audioPlayerState = AudioPlayerFeature.State()
        var errorMessage: String?
        
        @Presents var alert: AlertState<Never>?
    }
    
    enum Action {
        enum InnerAction {
            case loadBook(BookModel)
            case currentChapter(ChapterModel?)
            case configureChapter(ChapterModel?)
            case updateKeyPoint
        }
        
        case inner(InnerAction)
        case audioPlayerAction(AudioPlayerFeature.Action)
        case alert(PresentationAction<Never>)
    }
    
    @Dependency(\.chapterNavigatorClient) var chapterNavigator
    
    var body: some ReducerOf<Self> {
        Scope(state: \.audioPlayerState, action: \.audioPlayerAction) {
            AudioPlayerFeature()
        }
        
        Reduce { state, action in
            switch action {
            case let .inner(innerAction):
                switch innerAction {
                case let .loadBook(book):
                    state.book = book
                    return .run {  send in
                        await chapterNavigator.loadBook(book)
                        let chapter = await chapterNavigator.currentChapter()
                        let prev = await chapterNavigator.hasPreviousChapter()
                        let next = await chapterNavigator.hasNextChapter()
                        
                        await send(.inner(.currentChapter(chapter)))
                        await send(.audioPlayerAction(.inner(.play(chapter, shouldPlay: false))))
                        await send(.audioPlayerAction(.inner(.availableTrack(prev: prev, next: next))))
                    }
                    
                case let .currentChapter(chapter):
                    state.currentChapter = chapter
                    return .send(.inner(.updateKeyPoint))
                    
                case .updateKeyPoint:
                    guard
                        var index: Int = state.book?.chapters.firstIndex(where: { $0 == state.currentChapter }),
                        let count: Int = state.book?.chapters.count
                    else {
                        return .none
                    }
                    index += 1
                    state.keyPoint = Constants.keyPoint(current: index, total: count)
                    return .none
                    
                case let .configureChapter(chapter):
                    let shouldPlay = state.audioPlayerState.isPlaying
                    return .run { @MainActor send in
                        let prev = await chapterNavigator.hasPreviousChapter()
                        let next = await chapterNavigator.hasNextChapter()
                        send(.inner(.currentChapter(chapter)))
                        send(.audioPlayerAction(.inner(.play(chapter, shouldPlay: shouldPlay))))
                        send(.audioPlayerAction(.inner(.availableTrack(prev: prev, next: next))))
                    }
                }
                
            case let .audioPlayerAction(audioPlayerAction):
                switch audioPlayerAction {
                case let .delegate(delegateAction):
                    switch delegateAction {
                    case .onForward:
                        return .run { send in
                            var chapter = await chapterNavigator.nextChapter()
                            if chapter == nil {
                                chapter = await chapterNavigator.jumpToChapter(0)
                                await send(.audioPlayerAction(.inner(.pause)))
                            }
                            
                            guard let chapter else {
                                return await send(.audioPlayerAction(.inner(.pause)))
                            }
                            await send(.inner(.configureChapter(chapter)))
                        }
                        
                    case .onBackward:
                        return .run { send in
                            let chapter = await chapterNavigator.previousChapter()
                            guard let chapter else {
                                return
                            }
                            await send(.inner(.configureChapter(chapter)))
                        }
                        
                    case let .errorOccurred(error):
                        state.alert = AlertState { TextState(error.localizedDescription) }
                        return .none
                    }
                    
                default:
                    return .none
                }
                
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

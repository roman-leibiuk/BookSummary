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
        var book: BookModel?
        var currentChapter: ChapterModel?
        var image: URL?
        var keyPoint: String = ""
        var audioPlayerState = AudioPlayerFeature.State()
    }
    
    enum Action {
        enum ViewAction {
            case onAppear
        }
        
        enum InnerAction {
            case loadBook(BookModel)
            case currentChapter(ChapterModel?)
            case updateKeyPoint
        }
        
        case view(ViewAction)
        case inner(InnerAction)
        case audioPlayerAction(AudioPlayerFeature.Action)
    }
    
    @Dependency(\.chapterNavigatorClient) var chapterNavigator
    
    var body: some ReducerOf<Self> {
        Scope(state: \.audioPlayerState, action: \.audioPlayerAction) {
            AudioPlayerFeature()
        }
        
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .onAppear:
//                    return .send(.inner(.loadBook(.mock)))
                    return .none
                }
            case let .inner(innerAction):
                switch innerAction {
                case let .loadBook(book):
                    state.book = book
                    return .run { send in
                        await chapterNavigator.loadBook(book)
                        let chapter = await chapterNavigator.currentChapter()
                        let prev = await chapterNavigator.hasPreviousChapter()
                        let next = await chapterNavigator.hasNextChapter()
                        
                        await send(.inner(.currentChapter(chapter)))
                        await send(.audioPlayerAction(.inner(.play(chapter))))
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
                    state.keyPoint = "KEY POINT \(index) OF \(count)"
                    return .none
                }
                
            case let .audioPlayerAction(audioPlayerAction):
                switch audioPlayerAction {
                case let .delegate(delegateAction):
                    switch delegateAction {
                    case .onForward:
                        return .run { send in
                            let chapter = await chapterNavigator.nextChapter()
                            let prev = await chapterNavigator.hasPreviousChapter()
                            let next = await chapterNavigator.hasNextChapter()
                            await send(.inner(.currentChapter(chapter)))
                            await send(.audioPlayerAction(.inner(.play(chapter))))
                            await send(.audioPlayerAction(.inner(.availableTrack(prev: prev, next: next))))
                        }
                    case .onBackward:
                        return .run { send in
                            let chapter = await chapterNavigator.previousChapter()
                            let prev = await chapterNavigator.hasPreviousChapter()
                            let next = await chapterNavigator.hasNextChapter()
                            await send(.inner(.currentChapter(chapter)))
                            await send(.audioPlayerAction(.inner(.play(chapter))))
                            await send(.audioPlayerAction(.inner(.availableTrack(prev: prev, next: next))))
                        }
                    }
                default:
                    return .none
                }
            }
        }
    }
}

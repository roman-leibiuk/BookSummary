//
//  ChapterNavigatorClient.swift
//  BookSummary
//
//  Created by Roman Leibiuk on 17.02.2025.
//

import Dependencies

extension DependencyValues {
    var chapterNavigatorClient: ChapterNavigatorClient {
        get { self[ChapterNavigatorClient.self] }
        set { self[ChapterNavigatorClient.self] = newValue }
    }
}

public struct ChapterNavigatorClient {
    public var loadBook: @Sendable (BookModel) async -> Void
    public var currentChapter: @Sendable () async -> ChapterModel?
    public var hasNextChapter: @Sendable () async -> Bool
    public var hasPreviousChapter: @Sendable () async -> Bool
    public var nextChapter: @Sendable () async -> ChapterModel?
    public var previousChapter: @Sendable () async -> ChapterModel?
    public var jumpToChapter: @Sendable (Int) async -> ChapterModel?
}

extension ChapterNavigatorClient: DependencyKey {
    public static var liveValue: ChapterNavigatorClient {
        let navigator = ChapterNavigator()
        
        return Self(
            loadBook: { await navigator.loadBook($0) },
            currentChapter: { await navigator.currentChapter() },
            hasNextChapter: { await navigator.hasNextChapter() },
            hasPreviousChapter: { await navigator.hasPreviousChapter() },
            nextChapter: { await navigator.nextChapter() },
            previousChapter: { await navigator.previousChapter() },
            jumpToChapter: { index in await navigator.jumpToChapter(index: index) }
        )
    }
}

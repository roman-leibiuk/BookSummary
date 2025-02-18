//
//  ChapterNavigatorClient.swift
//  BookSummary
//
//  Created by Roman Leibiuk on 17.02.2025.
//

import Dependencies

extension DependencyValues {
    public var chapterNavigatorClient: ChapterNavigatorClient {
        get { self[ChapterNavigatorClient.self] }
        set { self[ChapterNavigatorClient.self] = newValue }
    }
}

public struct ChapterNavigatorClient: Sendable {
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
            loadBook: { await navigator.load(book: $0) },
            currentChapter: { await navigator.currentChapter() },
            hasNextChapter: { await navigator.hasNextChapter() },
            hasPreviousChapter: { await navigator.hasPreviousChapter() },
            nextChapter: { await navigator.nextChapter() },
            previousChapter: { await navigator.previousChapter() },
            jumpToChapter: { await navigator.jumpToChapter($0) }
        )
    }
    
    public static var testValue: ChapterNavigatorClient {
        return Self(
            loadBook: { _ in },
            currentChapter: { return ChapterModel(id: "1", title: "Chapter 1", imageUrl: nil, audioURL: nil) },
            hasNextChapter: { true },
            hasPreviousChapter: { false },
            nextChapter: { ChapterModel(id: "2", title: "Chapter 2", imageUrl: nil, audioURL: nil) },
            previousChapter: { ChapterModel(id: "0", title: "Chapter 0", imageUrl: nil, audioURL: nil) },
            jumpToChapter: { _ in ChapterModel(id: "0", title: "Chapter 0", imageUrl: nil, audioURL: nil) }
        )
    }
}


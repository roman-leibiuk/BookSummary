//
//  SummaryPlayerFeatureTests.swift
//  BookSummaryTests
//
//  Created by Roman Leibiuk on 15.02.2025.
//

import XCTest
import ComposableArchitecture
@testable import BookSummary
import AudioLibrary

@MainActor
final class SummaryPlayerFeatureTests: XCTestCase {
    
    var store: TestStore<SummaryPlayerFeature.State, SummaryPlayerFeature.Action>!
    
    func makeTestStore(book: BookModel?) -> TestStore<SummaryPlayerFeature.State, SummaryPlayerFeature.Action> {
        TestStore(initialState: SummaryPlayerFeature.State(book: book)) { SummaryPlayerFeature() }
        withDependencies: { $0.chapterNavigatorClient = .testValue }
    }
    
    override func setUp() {
        super.setUp()
        store = makeTestStore(book: Self.stubBook())
    }
    
    override func tearDown() {
        store = nil
        super.tearDown()
    }
    
    func testLoadBookAndUpdateChapter() async {
        store = makeTestStore(book: nil)
        let book = Self.stubBook()
        let chapter = book.chapters[0]
        
        await store.send(.inner(.loadBook(book))) {
            $0.book = book
        }
        
        await store.receive(.inner(.currentChapter(chapter))) {
            $0.currentChapter = chapter
        }
        
        await store.receive(.inner(.updateKeyPoint)) {
            $0.keyPoint = "KEY POINT 1 OF 3"
        }
        await store.skipReceivedActions()
    }
    
    func testCurrentChapter() async {
        let chapter = Self.stubBook().chapters[1]
        
        await store.send(.inner(.currentChapter(chapter))) {
            $0.currentChapter = chapter
        }
        
        await store.receive(.inner(.updateKeyPoint)) {
            $0.keyPoint = "KEY POINT 2 OF 3"
        }
    }
    
    func testUpdateKeyPoint() async {
        let chapter = Self.stubBook().chapters[2]
        
        await store.send(.inner(.currentChapter(chapter))) {
            $0.currentChapter = chapter
        }
        
        await store.receive(.inner(.updateKeyPoint)) {
            $0.keyPoint = "KEY POINT 3 OF 3"
        }
    }
}

private extension SummaryPlayerFeatureTests {
    private static func stubBook() -> BookModel {
        .init(chapters: [
            ChapterModel(id: "1", title: "Chapter 1", imageUrl: nil, audioURL: nil),
            ChapterModel(id: "2", title: "Chapter 2", imageUrl: nil, audioURL: nil),
            ChapterModel(id: "0", title: "Chapter 0", imageUrl: nil, audioURL: nil),
        ])
    }
}

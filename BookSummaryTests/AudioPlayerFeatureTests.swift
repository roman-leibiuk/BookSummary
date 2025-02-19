//
//  AudioPlayerFeatureTests.swift
//  BookSummary
//
//  Created by Roman Leibiuk on 18.02.2025.
//

import XCTest
import ComposableArchitecture
@testable import BookSummary
import AudioLibrary

@MainActor
final class AudioPlayerFeatureTests: XCTestCase {
    var store: TestStore<AudioPlayerFeature.State, AudioPlayerFeature.Action>!
    
    func makeTestStore() -> TestStore<AudioPlayerFeature.State, AudioPlayerFeature.Action> {
        TestStore(initialState: AudioPlayerFeature.State()) { AudioPlayerFeature() }
        withDependencies: { $0.audioPlayerClient = .testValue }
    }
    
    override func setUp() {
        super.setUp()
        store = makeTestStore()
    }
    
    override func tearDown() {
        store = nil
        super.tearDown()
    }
    
    func testPlayPauseToggle() async {
        await store.send(.inner(.readyToPlay(true))) {
                $0.isReadyToPlay = true
            }
        
        await store.send(.view(.onPlayPause))
        await store.receive(.inner(.resume)) {
            $0.isPlaying = true
        }
        
        await store.send(.view(.onPlayPause))
        await store.receive(.inner(.pause)) {
            $0.isPlaying = false
        }
    }
    
    func testSeekToTime() async {
        await store.send(.view(.seekToTime(50)))
        await store.receive(.inner(.seekToTime(50)))
    }
    
    func testSelectSpeed() async {
        await store.send(.view(.selectSpeed(1.5))) {
            $0.speed = 1.5
            $0.speedTitle = "Speed x1.5"
        }
    }
    
    func testPlayChapter() async {
        let chapter = ChapterModel(id: "1", title: "Test Chapter", imageUrl: nil, audioURL: nil)
        
        await store.send(.inner(.play(chapter, shouldPlay: true))) {
            $0.chapter = chapter
        }
        await store.receive(.inner(.updateTime))
        await store.receive(.inner(.readyToPlay(true))) {
            $0.isReadyToPlay = true
        }
        await store.receive(.inner(.resume)) {
            $0.isPlaying = true
        }
        await store.skipReceivedActions()
    }
    
    func testUpdateTime() async {
        await store.send(.inner(.updateTime))
        await store.receive(.inner(.setTotalTime(100))) {
            $0.totalTime = 100
        }
        await store.receive(.inner(.setCurrentTime(10))) {
            $0.currentTime = 10
        }
        await store.receive(.inner(.setCurrentTime(20))) {
            $0.currentTime = 20
        }
        await store.receive(.inner(.setCurrentTime(30))) {
            $0.currentTime = 30
        }
    }
}

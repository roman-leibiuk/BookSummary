//
//  AudioPlayerClient.swift
//  BookSummary
//
//  Created by Roman Leibiuk on 15.02.2025.
//

import AVFoundation
import Dependencies

extension DependencyValues {
    var audioPlayerClient: AudioPlayerClient {
        get { self[AudioPlayerClient.self] }
        set { self[AudioPlayerClient.self] = newValue }
    }
}

public struct AudioPlayerClient {
    public var play: @Sendable (ChapterModel) async -> AsyncStream<PlayerAction> = { _ in .finished }
    public var resume: @Sendable () async -> Void
    public var pause: @Sendable () async -> Void
    public var fastForward: @Sendable (TimeInterval) async -> Void
    public var rewind: @Sendable (TimeInterval) async -> Void
    public var seekTo: @Sendable (TimeInterval) async -> Void
    public var totalTime: @Sendable () async -> TimeInterval = { 0 }
    public var elapsedTimeUpdates: @Sendable () async -> AsyncStream<TimeInterval> = { .finished }
    public var playbackRate: @Sendable (Float) async -> Void
}

extension AudioPlayerClient: DependencyKey {
    public static var liveValue: AudioPlayerClient {
        let audioActor = AudioActor()
        return Self(
            play: { await audioActor.play(chapter: $0) },
            resume: { await audioActor.resume() },
            pause: { await audioActor.pause() },
            fastForward: { await audioActor.fastForward(seconds: $0) },
            rewind: { await audioActor.rewind(seconds: $0) },
            seekTo: { await audioActor.seekTo($0) },
            totalTime: { await audioActor.totalTime() },
            elapsedTimeUpdates: { await audioActor.elapsedTimeUpdates() },
            playbackRate: { await audioActor.setPlaybackRate($0) }
        )
    }
}

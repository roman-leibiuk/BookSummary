//
//  AudioPlayerClient.swift
//  BookSummary
//
//  Created by Roman Leibiuk on 17.02.2025.
//

import AVFoundation
import ComposableArchitecture
//import MediaPlayer

public enum PlayerAction {
    case readyToPlay
    case didPause
    case didResume
    case didFinish
    case error(Error)
}

actor AudioActor {
    private var player: AVPlayer?
    private var continuation: AsyncStream<PlayerAction>.Continuation?
    
    func play(chapter: ChapterModel) -> AsyncStream<PlayerAction> {
        guard let url = chapter.audioURL else {
            return .finished
        }
        
        player = AVPlayer(url: url)
        configureAudioSession()

        return AsyncStream { continuation in
            self.continuation = continuation
            guard let playerItem = player?.currentItem else { return }
            
            let didPlayToEndTimeNotification = NotificationCenter
                .default
                .publisher(for: AVPlayerItem.didPlayToEndTimeNotification)
                .sink { [weak self] _ in
                    continuation.yield(.didFinish)
                    Task {
                        Task { await self?.pause() }
                    }
                }
            let statusObserver = playerItem.observe(\.status, options: [.new]) { [weak self] item, _ in
                Task {
                    
                    guard let self, item.status == .readyToPlay else { return }
                    continuation.yield(.readyToPlay)
//                    await self.player?.play()
                    
                }
            }
            
            continuation.onTermination = { [weak self] _ in
                Task {
                    await self?.player?.pause()
                    await self?.clearContinuation()
                    statusObserver.invalidate()
                    didPlayToEndTimeNotification.cancel()
                }
            }
        }
    }
    
    func pause() async {
        player?.pause()
        continuation?.yield(.didPause)
    }
    
    func resume() async {
        player?.play()
        continuation?.yield(.didResume)
    }
    
    func fastForward(seconds: Double) async {
        guard let player else { return }
        let newTime = player.currentTime().seconds + seconds
        await player.seek(to: CMTime(seconds: newTime, preferredTimescale: 1))
    }
    
    func rewind(seconds: Double) async {
        guard let player else { return }
        let newTime = max(0, player.currentTime().seconds - seconds)
        await player.seek(to: CMTime(seconds: newTime, preferredTimescale: 1))
    }
    
    func seekTo(_ timeInterval: TimeInterval) async {
        guard let player else { return }
        await player.seek(to: CMTime(seconds: timeInterval, preferredTimescale: 1))
    }
    
    func elapsedTime() -> TimeInterval {
        return player?.currentTime().seconds ?? 0
    }
    
    func totalTime() -> TimeInterval {
        guard let player = player, let currentItem = player.currentItem else {
            print("totalTime(): No player or currentItem")
            return 0
        }
        
        let duration = currentItem.duration
        if duration.isIndefinite || duration.seconds.isNaN {
            print("totalTime(): Duration is indefinite or NaN")
            return 0
        }
        
        return duration.seconds
    }
    
    func elapsedTimeUpdates(interval: CMTime = CMTime(seconds: 0.1, preferredTimescale: 10)) -> AsyncStream<TimeInterval> {
        AsyncStream { continuation in
            guard let player else { return }
            let observer = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
                continuation.yield(time.seconds)
            }
            
            continuation.onTermination = { [weak self] _ in
                Task {
                    await self?.player?.removeTimeObserver(observer)
                }
            }
        }
    }
    
    func setPlaybackRate(_ rate: Float) {
        player?.rate = rate
    }
}

private extension AudioActor {
    func stopPlayback() {
        player?.pause()
        continuation?.finish()
        continuation = nil
        player = nil
    }
    
    func clearContinuation() {
        continuation = nil
    }
    
    func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
}

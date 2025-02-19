//
//  AudioActor.swift
//  BookSummary
//
//  Created by Roman Leibiuk on 17.02.2025.
//

import AVFoundation
import ComposableArchitecture
import Combine

public enum PlayerAction: Sendable {
    case readyToPlay
    case didFinish
    case error(String)
}

public actor AudioActor {
    enum Constants {
        static let failedToLoad = "Failed to load audio item"
        static let unknownError = "Unknown error: AudioPlayer Failed"
        static func errorDescription(_ error: String) -> Error {
            NSError(domain: "AudioPlayer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to load audio item"])
        }
    }
    
    private var player: AVPlayer = .init()
    private var continuation: AsyncStream<PlayerAction>.Continuation?
    private var statusObserver: NSKeyValueObservation?
    private var didPlayToEndTimeNotification: AnyCancellable?
    private var asyncStream: AsyncStream<PlayerAction>?

    private var elapseTimeStream: AsyncStream<TimeInterval>.Continuation?
    private var timeAsyncStream: AsyncStream<TimeInterval>?
    private var timeObserver: Any?
    
    public func play(chapter: ChapterModel) async -> AsyncStream<PlayerAction> {
        guard let url = chapter.audioURL else {
            return .finished
        }
        
        let newItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: newItem)
        
        let stream = AsyncStream { continuation in
            self.continuation = continuation
            
            guard let playerItem = player.currentItem else {
                continuation.yield(.error(Constants.failedToLoad))
                return
            }
            
            self.didPlayToEndTimeNotification = NotificationCenter
                .default
                .publisher(for: AVPlayerItem.didPlayToEndTimeNotification)
                .sink { _ in
                    continuation.yield(.didFinish)
                    continuation.finish()
                }
            
            self.statusObserver = playerItem.observe(\ .status, options: [.new]) { item, _ in
                Task {
                    switch item.status {
                    case .readyToPlay:
                        continuation.yield(.readyToPlay)
                    case .failed:
                        guard let error = item.error else {
                            continuation.yield(.error(Constants.unknownError))
                            return
                        }
                        continuation.yield(.error(error.localizedDescription))
                    default:
                        break
                    }
                }
            }
            
            continuation.onTermination = { [weak self] _ in
                Task { await self?.clearContinuation() }
            }
        }
        
        asyncStream = stream
        return stream
    }
    
    public func pause() async {
        player.pause()
    }
    
    public func resume() async {
        player.play()
    }
    
    public func fastForward(seconds: Double) async {
        let newTime = player.currentTime().seconds + seconds
        await player.seek(to: CMTime(seconds: newTime, preferredTimescale: 1))
    }
    
    public func rewind(seconds: Double) async {
        let newTime = max(0, player.currentTime().seconds - seconds)
        await player.seek(to: CMTime(seconds: newTime, preferredTimescale: 1))
    }
    
    public func seekTo(_ timeInterval: TimeInterval) async {
        await player.seek(to: CMTime(seconds: timeInterval, preferredTimescale: 1))
    }
    
    public func totalTime() -> TimeInterval {
        guard let currentItem = player.currentItem else {
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
    
    public func elapsedTimeUpdates(interval: CMTime = CMTime(seconds: 1, preferredTimescale: 1)) -> AsyncStream<TimeInterval> {
        return AsyncStream { continuation in
            elapseTimeStream = continuation
            timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
                continuation.yield(time.seconds)
            }
            continuation.onTermination = { [weak self] _ in
                guard let self else { return }
                Task {
                    await removeTimeObserver()
                }
            }
        }
    }
    
    @MainActor
    public func setPlaybackRate(_ rate: Float) async {
        await player.rate = rate
    }
}

private extension AudioActor {
    func clearContinuation() async {
        continuation?.finish()
        continuation = nil
        asyncStream = nil
        statusObserver?.invalidate()
        statusObserver = nil
        didPlayToEndTimeNotification?.cancel()
        didPlayToEndTimeNotification = nil
        await removeTimeObserver()
    }
    
    func removeTimeObserver() async {
        guard let observer = timeObserver else { return }
        player.removeTimeObserver(observer)
        elapseTimeStream?.finish()
        timeObserver = nil
        timeAsyncStream = nil
    }
}

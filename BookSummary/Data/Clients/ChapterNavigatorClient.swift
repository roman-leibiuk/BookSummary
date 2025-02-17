public struct ChapterNavigatorClient {
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
            currentChapter: { await navigator.currentChapter() },
            hasNextChapter: { await navigator.hasNextChapter() },
            hasPreviousChapter: { await navigator.hasPreviousChapter() },
            nextChapter: { await navigator.nextChapter() },
            previousChapter: { await navigator.previousChapter() },
            jumpToChapter: { index in await navigator.jumpToChapter(index: index) }
        )
    }
}
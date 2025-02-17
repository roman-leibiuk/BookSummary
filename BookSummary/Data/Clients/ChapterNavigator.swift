public actor ChapterNavigator {
    private var book: BookModel?
    private var currentIndex: Int = 0
    
    public func loadBook(_ newBook: BookModel) {
        book = newBook
        currentIndex = 0
    }
    
    public func currentChapter() -> ChapterModel? {
        book?.chapters.isEmpty == false ? book?.chapters[currentIndex] : nil
    }
    
    public func hasNextChapter() -> Bool {
        guard let book else { return false }
        return currentIndex < book.chapters.count - 1
    }
    
    public func hasPreviousChapter() -> Bool {
        return currentIndex > 0
    }
    
    public func nextChapter() -> ChapterModel? {
        guard hasNextChapter() else { return nil }
        currentIndex += 1
        return currentChapter()
    }
    
    public func previousChapter() -> ChapterModel? {
        guard hasPreviousChapter() else { return nil }
        currentIndex -= 1
        return currentChapter()
    }
    
    public func jumpToChapter(index: Int) -> ChapterModel? {
        guard let book, index >= 0, index < book.chapters.count else { return nil }
        currentIndex = index
        return currentChapter()
    }
}

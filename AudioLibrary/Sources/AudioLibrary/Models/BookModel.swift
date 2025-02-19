//
//  BookModel.swift
//  BookSummary
//
//  Created by Roman Leibiuk on 15.02.2025.
//

import Foundation

public struct BookModel: Equatable, Sendable {
    public let chapters: [ChapterModel]
    
    public init(chapters: [ChapterModel]) {
        self.chapters = chapters
    }
}

extension BookModel {
    public static func == (lhs: BookModel, rhs: BookModel) -> Bool {
        return lhs.chapters == rhs.chapters
    }
}

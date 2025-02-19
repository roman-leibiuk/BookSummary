//
//  ChapterModel.swift
//  BookSummary
//
//  Created by Roman Leibiuk on 15.02.2025.
//

import Foundation

public struct ChapterModel: Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let imageUrl: URL?
    public let audioURL: URL?
    
    public init(
        id: String,
        title: String,
        imageUrl: URL? = nil,
        audioURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.imageUrl = imageUrl
        self.audioURL = audioURL
    }
}

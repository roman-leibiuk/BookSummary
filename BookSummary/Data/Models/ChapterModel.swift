//
//  ChapterModel.swift
//  BookSummary
//
//  Created by Roman Leibiuk on 15.02.2025.
//

import Foundation

public struct ChapterModel: Equatable, Identifiable {
    public let id: String
    public let title: String
    public var imageUrl: URL?
    public var audioURL: URL?
}

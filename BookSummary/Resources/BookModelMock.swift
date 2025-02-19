//
//  BookModelMock.swift
//  BookSummary
//
//  Created by Roman Leibiuk on 18.02.2025.
//

import Foundation
import AudioLibrary

extension BookModel {
    static let mock: BookModel = .init(chapters: (1...36).map { configureLittlePrince(by: $0) } )
    
    static private func configureLittlePrince(by chapter: Int) -> ChapterModel {
        let idByChapter = String(format: "%02d", chapter)
        let imageURL = URL(string: "https://kancelyaria.com.ua/files/resized/products/rnk_512076_1.490x490.jpg")
        let audioURL = URL(string: "https://arch.sound-books.net/262/Track_02_\(idByChapter).mp3")
        let title = chapter > 1
        ? "Маленький Принц. Розділ \(chapter)"
        : "Маленький Принц. Вступ та розділ \(chapter)"
      
        return .init(id: idByChapter, title: title, imageUrl: imageURL, audioURL: audioURL)
    }
}

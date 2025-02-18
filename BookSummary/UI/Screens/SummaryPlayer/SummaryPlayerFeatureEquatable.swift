//
//  SummaryPlayerFeatureEquatable.swift
//  BookSummary
//
//  Created by Roman Leibiuk on 18.02.2025.
//

import Foundation
import ComposableArchitecture
import AudioLibrary

extension SummaryPlayerFeature.State {
    static func == (lhs: SummaryPlayerFeature.State, rhs: SummaryPlayerFeature.State) -> Bool {
        return lhs.book == rhs.book &&
        lhs.currentChapter == rhs.currentChapter &&
        lhs.image == rhs.image &&
        lhs.keyPoint == rhs.keyPoint &&
        lhs.audioPlayerState == rhs.audioPlayerState &&
        lhs.errorMessage == rhs.errorMessage &&
        lhs.alert == rhs.alert
    }
}

extension SummaryPlayerFeature.Action {
    static func == (lhs: SummaryPlayerFeature.Action, rhs: SummaryPlayerFeature.Action) -> Bool {
        switch (lhs, rhs) {
        case let (.inner(lhsAction), .inner(rhsAction)):
            return lhsAction == rhsAction
        case let (.audioPlayerAction(lhsAction), .audioPlayerAction(rhsAction)):
            return lhsAction == rhsAction
        case let (.alert(lhsAction), .alert(rhsAction)):
            return lhsAction == rhsAction
        default:
            return false
        }
    }
}

extension SummaryPlayerFeature.Action.InnerAction {
    static func == (lhs: SummaryPlayerFeature.Action.InnerAction, rhs: SummaryPlayerFeature.Action.InnerAction) -> Bool {
        switch (lhs, rhs) {
        case let (.loadBook(lhsBook), .loadBook(rhsBook)):
            return lhsBook.chapters == rhsBook.chapters
        case let (.currentChapter(lhsChapter), .currentChapter(rhsChapter)):
            return lhsChapter == rhsChapter
        case let (.configureChapter(lhsChapter), .configureChapter(rhsChapter)):
            return lhsChapter == rhsChapter
        case (.updateKeyPoint, .updateKeyPoint):
            return true
        default:
            return false
        }
    }
}

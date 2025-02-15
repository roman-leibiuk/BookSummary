//
//  AppFeature.swift
//  BookSummary
//
//  Created by Roman Leibiuk on 15.02.2025.
//

import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {
    
    @ObservableState
    enum State {
        case summaryPlayer(SummaryPlayerFeature.State)
        
        init() {
            self = .summaryPlayer(SummaryPlayerFeature.State())
        }
    }
    
    enum Action {
        enum AppDelegateAction: Equatable {
            case didFinishLaunching
        }
        
        case appDelegate(AppDelegateAction)
        case summaryPlayerAction(SummaryPlayerFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .appDelegate(appDelegateAction):
                switch appDelegateAction {
                case .didFinishLaunching:
                    return .none
                }
            default:
                return .none
            }
        }
        .ifCaseLet(\.summaryPlayer, action: \.summaryPlayerAction) {
            SummaryPlayerFeature()
        }
    }
}

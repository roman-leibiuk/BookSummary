//
//  AudioTimeLineView.swift
//  BookSummary
//
//  Created by Roman Leibiuk on 17.02.2025.
//

import SwiftUI

struct AudioTimeLineView: View {
    var currentTime: TimeInterval
    
    var totalTime: TimeInterval
    var onDragEnded: (TimeInterval) -> Void = { _ in }
    
    @State private var dragOffset: CGFloat = .zero
    @State private var isDragging: Bool = false
    @State private var progressAnimation: Animation? = .linear(duration: 1)
    
    var body: some View {
        content
    }
    
    func updateOffset(currentTime: Double, width: CGFloat) -> CGFloat {
        (width / totalTime) * currentTime
    }
    
    func updateCurrentTime(dragOffset: CGFloat, width: CGFloat) -> CGFloat {
        (dragOffset / width) * totalTime
    }
    
    func format(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

private extension AudioTimeLineView {
    var content: some View {
        HStack(spacing: Spacing.xs) {
            text(with: currentTime)
            audioTimeLine
            text(with: totalTime - currentTime)
        }
        .frame(height: Spacing.md)
    }
    
    var audioTimeLine: some View {
        GeometryReader { geometry in
            let width = geometry.size.width - Spacing.mdlg
            progress
                .frame(width: geometry.size.width)
                .onChange(of: currentTime) { oldValue, newValue in
                    guard !isDragging else { return }
                    let difference = abs(newValue - oldValue)
                    progressAnimation = newValue == 0 || difference > 2
                    ? nil
                    : .linear(duration: 1)
                    withAnimation(progressAnimation) {
                        dragOffset = updateOffset(currentTime: newValue, width: width)
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = min(max(0, value.location.x), width)
                            isDragging = true
                        }
                        .onEnded { value in
                            dragOffset = min(max(0, value.location.x), width)
                            let newValue = updateCurrentTime(dragOffset: dragOffset, width: width)
                            onDragEnded(newValue)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isDragging = false
                            }
                        }
                )
        }
    }
    
    var progress: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(.appGreyProgress)
                .frame(height: Spacing.xs)
            
            Capsule()
                .fill(.appSecondBlue)
                .frame(width: dragOffset + Spacing.sm, height: Spacing.xs)
            
            Circle()
                .fill(.accent)
                .frame(width: Spacing.mdlg, height: Spacing.mdlg)
                .offset(x: dragOffset)
        }
    }
    
    func text(with time: TimeInterval) -> some View {
        Text(format(time: time))
            .font(.system(size: 13))
            .foregroundStyle(.appGreyText)
            .frame(width: Spacing.xxl)
    }
}

#Preview {
    AudioTimeLineView(currentTime: 50, totalTime: 100) {_ in }
}

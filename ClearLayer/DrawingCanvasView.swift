//
//  DrawingCanvasView.swift
//  ClearLayer
//
//  Created by 中里祐希 on 2025/05/20.
//

import SwiftUI
import UIKit

struct DrawingCanvasView: View {
    @ObservedObject var drawVM: DrawingViewModel
    @ObservedObject var settings: SettingModel
    
    @State private var lastTapTime: Date?
    @State private var lastTapCount: Int = 0
    @State private var showSaveConfirmation = false
    @State private var doubleTapWork: DispatchWorkItem?
    

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(drawVM.lines.indices, id: \.self) { index in
                    Path { path in
                        let points = drawVM.lines[index].points
                        guard let first = points.first else { return }
                        path.move(to: first)
                        for point in points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                    .stroke(drawVM.lines[index].color, lineWidth: drawVM.lines[index].width) // ← 各線ごとの太さ
                }

                Path { path in
                    guard let first = drawVM.currentLine.points.first else { return }
                    path.move(to: first)
                    for point in drawVM.currentLine.points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                .stroke(drawVM.currentLine.color, lineWidth: drawVM.currentLine.width) // ← 現在の線も太さを指定
                
                if showSaveConfirmation {
                    Text("スクリーンショットを保存しました。")
                        .font(.caption)
                        .padding(6)
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        .transition(.opacity)
                        .padding(.top, 60)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0.1)
                    .onChanged { value in
                        let newPoint = value.location
                        if drawVM.currentLine.points.isEmpty {
                            drawVM.currentLine = DrawingViewModel.Line(points: [newPoint], color: drawVM.selectedColor, width: drawVM.lineWidth)
                        } else {
                            drawVM.currentLine.points.append(newPoint)
                        }
                        if drawVM.isEraserOn {
                            let threshold: CGFloat = 10 // 消しゴムの閾値
                            drawVM.lines.removeAll { line in
                                line.points.contains { point in
                                    hypot(point.x - newPoint.x, point.y - newPoint.y) < threshold
                                }
                            }
                        }
                    }
                    .onEnded { _ in
                        if !drawVM.isEraserOn {
                            drawVM.lines.append(drawVM.currentLine)
                        }
                        // 開始⇔終了距離
                        let distSE: CGFloat
                        if let first = drawVM.currentLine.points.first, let last = drawVM.currentLine.points.last {
                            distSE = hypot(last.x - first.x, last.y - first.y)
                        } else {
                            distSE = .infinity
                        }
                        // 描画範囲が一定より狭い場合タップ判定
                        if distSE <= TapThreshold.maxStartEndDistance {
                            // → タップとして扱う
                            let now = Date()
                            if let last = lastTapTime,
                               now.timeIntervalSince(last) <= TapThreshold.maxInterval {
                                lastTapCount += 1
                            } else {
                                lastTapCount = 1
                            }
                            lastTapTime = now

                            switch lastTapCount {
                            case 2:
                                if settings.useDoubleTapGesture && settings.isGestureUnlocked {
                                    let work = DispatchWorkItem {
                                        // ダブルタップ時の機能切り替え
                                        if !drawVM.isEraserOn { drawVM.deleteGestureTap(at: lastTapCount) }
                                        drawVM.toggleEraser()
                                    }
                                    doubleTapWork = work
                                    DispatchQueue.main.asyncAfter(deadline: .now() + TapThreshold.maxInterval, execute: work)
                                }
                            case 3:
                                if settings.useTripleTapGesture && settings.isGestureUnlocked {
                                    doubleTapWork?.cancel()
                                    if !drawVM.isEraserOn { drawVM.deleteGestureTap(at: lastTapCount) }
                                    drawVM.takeScreenshot()
                                }
                            default:
                                break
                            }
                        }
                        drawVM.currentLine = DrawingViewModel.Line(points: [], color: drawVM.selectedColor, width: drawVM.lineWidth)
                    }
            )
        }
        .onChange(of: drawVM.clearCanvas) {
            drawVM.lines = []
        }
    }
}

/// タップとストローク判定用の閾値
fileprivate struct TapThreshold {
    static let maxStrokeLength: CGFloat = 20        // 総描画長がこれ以下ならタップ
    static let maxStartEndDistance: CGFloat = 2.5    // 開始⇔終了距離がこれ以下ならタップ
    static let maxInterval: TimeInterval = 0.5      // 連続タップを判定する間隔
}

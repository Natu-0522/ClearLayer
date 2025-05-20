//
//  DrawingCanvasView.swift
//  ClearLayer
//
//  Created by 中里祐希 on 2025/05/20.
//

import SwiftUI

struct DrawingCanvasView: View {
    var strokeColor: Color
    var isEraser: Bool
    @Binding var clearTrigger: Bool
    @Binding var lines: [Line]
    @Binding var currentLine: Line
    var lineWidth: CGFloat

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(lines.indices, id: \.self) { index in
                    Path { path in
                        let points = lines[index].points
                        guard let first = points.first else { return }
                        path.move(to: first)
                        for point in points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                    .stroke(lines[index].color, lineWidth: lines[index].width) // ← 各線ごとの太さ
                }

                Path { path in
                    guard let first = currentLine.points.first else { return }
                    path.move(to: first)
                    for point in currentLine.points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                .stroke(currentLine.color, lineWidth: currentLine.width) // ← 現在の線も太さを指定
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0.1)
                    .onChanged { value in
                        let newPoint = value.location
                        if isEraser {
                            let threshold: CGFloat = 20
                            lines.removeAll { line in
                                line.points.contains { point in
                                    hypot(point.x - newPoint.x, point.y - newPoint.y) < threshold
                                }
                            }
                        } else {
                            if currentLine.points.isEmpty {
                                currentLine = Line(points: [newPoint], color: strokeColor, width: lineWidth)
                            } else {
                                currentLine.points.append(newPoint)
                            }
                        }
                    }
                    .onEnded { _ in
                        if !isEraser {
                            lines.append(currentLine)
                        }
                        currentLine = Line(points: [], color: strokeColor, width: lineWidth)
                    }
            )
        }
        .onChange(of: clearTrigger) {
            lines = []
        }
    }

    struct Line {
        var points: [CGPoint]
        var color: Color
        var width: CGFloat
    }
}

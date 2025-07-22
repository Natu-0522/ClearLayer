//
//  Toolbox.swift
//  ClearLayer
//
//  Created by 中里祐希 on 2025/07/14.
//

// DrawingToolbox.swift
import SwiftUI

struct Toolbox: View {
    
    @ObservedObject var webVM: WebViewModel
    @ObservedObject var drawVM: DrawingViewModel
    @State private var isPalettePresented = false
    
    var body: some View {
        if drawVM.isFullToolboxVisible{
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Button {
                        isPalettePresented.toggle()
                    } label: {
                        Circle()
                            .fill(drawVM.selectedColor)
                            .frame(width: 36, height: 36)
                            .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                    }
                    // ここで popover を指定
                    .popover(isPresented: $isPalettePresented, attachmentAnchor: .rect(.bounds), arrowEdge: .bottom) {
                        ColorPaletteView(
                            isPresented: $isPalettePresented,
                            selectedColor: $drawVM.selectedColor
                        )
                        .padding()
                    }

                    Button(action: {
                        drawVM.isEraserOn.toggle()
                    }) {
                        Image(systemName: drawVM.isEraserOn ? "eraser.fill" : "pencil")
                            .foregroundColor(.primary)
                    }

                    Button(action: {
                        drawVM.clearCanvas.toggle()
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.primary)
                    }

                    Button {
                        webVM.togglePlayPause()
                    } label: {
                        Image(systemName: "playpause")
                            .foregroundColor(.primary)
                    }
                    Button(action: {
                        withAnimation {
                            drawVM.showDrawing.toggle()
                            drawVM.triggerSweepEffect = true
                        }
                    }) {
                        Image(systemName: drawVM.showDrawing ? "eye.slash" : "square.2.layers.3d")
                            .foregroundColor(.primary)
                    }
                }

                Slider(value: $drawVM.lineWidth, in: 1...10, step: 1)
                    .frame(width: 100)
                    .foregroundColor(.primary)

                Picker("", selection: $drawVM.mode) {
                    Text("YT").tag("youtube")
                    Text("Web").tag("browser")
                }
                .pickerStyle(.segmented)
                .frame(width: 150)
                .onChange(of: drawVM.mode) {
                    let newURL = URL(string: drawVM.mode == "youtube" ? "https://www.youtube.com" : "https://www.google.com")!
                    drawVM.currentURL = newURL
                    drawVM.urlString = newURL.absoluteString
                    drawVM.showDrawing = false
                    webVM.load(newURL)
                    withAnimation {
                        drawVM.showModeText = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            drawVM.showModeText = false
                        }
                    }
                }

                HStack {
                    Button("⚙️ 設定") {
                    }
                    Button {
                        withAnimation {
                            drawVM.isFullToolboxVisible = false
                        }
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.title)
                            .foregroundColor(.primary)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .padding(.trailing, 20)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .trailing)
        } else {
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Button {
                        isPalettePresented.toggle()
                    } label: {
                        Circle()
                            .fill(drawVM.selectedColor)
                            .frame(width: 36, height: 36)
                            .overlay(Circle().stroke(Color.clear, lineWidth: 2))
                    }
                    // ここで popover を指定
                    .popover(isPresented: $isPalettePresented, attachmentAnchor: .rect(.bounds), arrowEdge: .bottom) {
                        ColorPaletteView(
                            isPresented: $isPalettePresented,
                            selectedColor: $drawVM.selectedColor
                        )
                        .padding()
                    }
                    
                    Slider(value: $drawVM.lineWidth, in: 1...10, step: 1)
                        .frame(width: 100)
                        .foregroundColor(.primary)
                }
                HStack(spacing: 12) {
                    Button(action: {
                        drawVM.toggleEraser()
                    }) {
                        Image(systemName: drawVM.isEraserOn ? "eraser.fill" : "pencil")
                            .foregroundColor(.primary)
                    }

                    Button(action: {
                        drawVM.clearCanvas.toggle()
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.primary)
                    }

                    Button {
                        webVM.togglePlayPause()
                    } label: {
                        Image(systemName: "playpause")
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {
                        withAnimation {
                            drawVM.showDrawing.toggle()
                            drawVM.triggerSweepEffect = true
                        }
                    }) {
                        Image(systemName: drawVM.showDrawing ? "square.2.layers.3d.bottom.filled" : "diamond.fill")
                            .foregroundColor(.primary)
                            .symbolRenderingMode(.hierarchical)
                            .rotationEffect(.degrees(drawVM.showDrawing ? 0 : 180))
                            .animation(.easeInOut(duration: 0.3), value: drawVM.showDrawing)
                    }
                }
            }
            .padding(10)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .padding(.bottom, 20)
            .padding(.trailing, 20)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        
        if drawVM.showModeText {
            Text("mode: \(drawVM.mode)")
            .font(.caption)
            .padding(6)
            .background(.ultraThinMaterial)
            .cornerRadius(10)
            .transition(.opacity)
            .padding(.top, 60)
        }
    }
}

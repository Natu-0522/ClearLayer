//
//  ContentView.swift
//  ClearLayer
//
//  Created by 中里祐希 on 2025/05/20.
//

import SwiftUI
import WebKit

struct ContentView: View {
    @State private var selectedColor: Color = .black
    @State private var isEraserOn = false
    @State private var clearCanvas = false
    @State private var showDrawing = false
    @State private var lineWidth: CGFloat = 3

    @State private var lines: [DrawingCanvasView.Line] = []
    @State private var currentLine = DrawingCanvasView.Line(points: [], color: .black, width: 3)
    @State private var webView: WKWebView? = nil

    @State private var mode: String = "youtube"
    @State private var currentURL: URL = URL(string: "https://www.youtube.com")!
    @State private var showModeText = false

    var body: some View {
        ZStack {
            WebViewWrapper(
                url: currentURL,
                webView: $webView
            )

            if showDrawing {
                DrawingCanvasView(
                    strokeColor: isEraserOn ? .clear : selectedColor,
                    isEraser: isEraserOn,
                    clearTrigger: $clearCanvas,
                    lines: $lines,
                    currentLine: $currentLine,
                    lineWidth: lineWidth
                )
                .allowsHitTesting(true)
            }

            VStack {
                Spacer()

                // ✅ 描画ツールバー内に統合されたモード切り替え含むUI
                HStack {
                    ColorPicker("", selection: $selectedColor)
                        .labelsHidden()
                        .frame(width: 44)

                    Slider(value: $lineWidth, in: 1...10, step: 1)
                        .frame(width: 100)

                    Button(action: {
                        isEraserOn.toggle()
                    }) {
                        Image(systemName: isEraserOn ? "eraser.fill" : "pencil")
                    }

                    Button(action: {
                        clearCanvas.toggle()
                    }) {
                        Image(systemName: "trash")
                    }

                    Button(action: {
                        showDrawing.toggle()
                    }) {
                        Image(systemName: showDrawing ? "eye.slash" : "eye")
                    }

                    Button(action: {
                        webView?.evaluateJavaScript("""
                            var video = document.querySelector('video');
                            if (video) {
                                if (video.paused) {
                                    video.play();
                                } else {
                                    video.pause();
                                }
                            }
                        """)
                    }) {
                        Image(systemName: "playpause")
                    }

                    // ✅ モードトグルをここに統合
                    Picker("", selection: $mode) {
                        Text("YT").tag("youtube")
                        Text("Web").tag("browser")
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 120)
                    .onChange(of: mode) {
                        currentURL = URL(string: mode == "youtube" ? "https://www.youtube.com" : "https://www.google.com")!
                        showDrawing = false
                        withAnimation {
                            showModeText = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                showModeText = false
                            }
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .padding(.bottom)
            }

            if showModeText {
                Text("mode: \(mode)")
                    .font(.caption)
                    .padding(6)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .transition(.opacity)
                    .padding(.top, 60)
            }
        }
        .ignoresSafeArea()
    }
}

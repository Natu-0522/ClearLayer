////
////  ContentView.swift
////  ClearLayer
////
////  Created by 中里祐希 on 2025/05/20.
////

import SwiftUI

struct ContentView: View {
    @StateObject private var webVM = WebViewModel(initialURL: URL(string: "https://www.youtube.com")!)
    @StateObject private var drawVM = DrawingViewModel()
    @StateObject private var settings = SettingModel()
    @FocusState private var urlFieldIsFocused: Bool
    @State private var sweepOffset: CGSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    @State private var delayedShow = false
    @State private var showScreenshotOverlay = false
    
    @AppStorage("hasSeenTutorial") var hasSeenTutorial = false
    @State private var activeSheet: ActiveSheet? = nil
    
    
    var body: some View {
        ZStack{
            VStack(spacing: 0) {
                BrowserTabBar(
                    webVM: webVM,
                    drawVM: drawVM,
                    urlFieldIsFocused: _urlFieldIsFocused,
                    activeSheet: $activeSheet
                )
                .padding(8)
                .background(drawVM.showDrawing
                            ? Color.blue.opacity(0.3)
                            : Color(UIColor.systemGray6))
                .animation(Animation.easeInOut(duration: 0.4).delay(0.2), value: drawVM.showDrawing)
                
                ZStack {
                    WebViewWrapper(viewModel: webVM)
                        .edgesIgnoringSafeArea(.all)
                    
                    ZStack {
                        if delayedShow {
                            DrawingCanvasView(drawVM: drawVM,settings: settings)
                                .transition(.opacity)
                        }
                    }
                    // drawVM.showDrawing が変わったら delayedShow を遅延更新
                    .onChange(of: drawVM.showDrawing) { oldValue, newValue in
                        if newValue {
                            // showDrawing == true のときは 遅延してフェードイン
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    delayedShow = true
                                }
                            }
                        } else {
                            // showDrawing == false のときは即座に（または任意の delay で）フェードアウト
                            withAnimation(.easeInOut(duration: 0.4)) {
                                delayedShow = false
                            }
                        }
                    }
                    
                    VStack {
                        Spacer()
                        Toolbox(webVM: webVM, drawVM: drawVM)
                            .padding(.trailing)
                            .disabled(drawVM.triggerSweepEffect)
                    }
                    if showScreenshotOverlay {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .transition(.opacity)
                        
                        Text("スクリーンショットを保存しました")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .overlay(
                    Group {
                        if drawVM.triggerSweepEffect {
                            SweepEffectView(isActive: $drawVM.triggerSweepEffect,
                                            sweepOffset: $sweepOffset,
                                            isTurningOn: drawVM.showDrawing)
                        }
                    }
                )
                .frame(maxHeight: .infinity)
                // ─── ここにバナー広告エリア ─────────────────────
                BannerAdView(adUnitID: "ca-app-pub-8866672716864480/9063026208")
                    .frame(width: UIScreen.main.bounds.width, height: 60)
            }
            // Safe area の下部にぴったり表示
            .ignoresSafeArea(edges: .bottom)
            .animation(.easeInOut(duration: 0.3), value: showScreenshotOverlay)
            // ここで ViewModel の通知に応じてオンオフ
            .onReceive(drawVM.$didTakeScreenshot) { didTake in
                guard didTake else { return }
                // オーバーレイを表示
                showScreenshotOverlay = true
                // 1秒後に自動で消す
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        showScreenshotOverlay = false
                    }
                    // フラグをクリア
                    drawVM.didTakeScreenshot = false
                }
            }
            .onAppear {
                if !hasSeenTutorial {
                    activeSheet = .tutorial
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .settings:
                    SettingsView(webVM: webVM,drawVM: drawVM, activeSheet: $activeSheet)
                case .tutorial:
                    TutorialPageView(activeSheet: $activeSheet)
                case .privacy:
                    PrivacyPolicyView()
                }
            }
        }
    }
}
enum ActiveSheet: Identifiable {
    case settings
    case tutorial
    case privacy
    
    var id: Int { hashValue }
}

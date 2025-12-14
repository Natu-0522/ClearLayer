//
//  TutorialPageView.swift
//  ClearLayer
//
//  Created by 中里祐希 on 2025/07/22.
//
import SwiftUI

struct TutorialPageView: View {
    @Binding var activeSheet: ActiveSheet?
    @State private var currentPage = 0

    let onFinished: () -> Void
    
    let tutorialPages = [
        TutorialPage(
            title: String(localized: "tutorial.welcome.title"),
            descriptionView: AnyView(
                        VStack(spacing: 12) {
                            Text("ご利用ありがとうございます！")
                            Text("このアプリは、YouTubeやWebページに\n透明な紙（レイヤー）を重ね\n直接文字や線を書き込めるようにした\n学習・作業サポートツールです。")
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    )
        ),
        TutorialPage(
            title: String(localized: "tutorial.toolbox.title"),
            descriptionView: AnyView(
                        VStack(spacing: 12) {
                            Text("画面右下にツールボックスが表示されています。")
                            HStack(spacing: 8) {
                                Image(systemName: "pencil.tip")
                                Text("/")
                                Image(systemName: "eraser.fill")
                                Text("ペンと消しゴムの切り替え")
                            }
                            HStack(spacing: 8) {
                                Image(systemName: "trash")
                                Text("リセット")
                            }
                            HStack(spacing: 8) {
                                Image(systemName: "playpause")
                                Text("色々な動画の再生・一時停止")
                            }
                            HStack(spacing: 8) {
                                Image(systemName: "diamond.fill")
                                Text("/")
                                Image(systemName: "square.2.layers.3d.bottom.filled")
                                Text("レイヤーの表示切り替え")
                            }
                            HStack(spacing: 8) {
                                Text("また、ペンの色や太さを変更することもできます。")
                            }
                        }
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                    )
        ),
        TutorialPage(
            title: String(localized: "tutorial.settings.title"),
            descriptionView: AnyView(
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "gearshape.fill")
                                Text("画面左上から設定を開けます。")
                            }
                            
                            Text("ご意見や「こんな機能が欲しい」など、")
                            Text("ぜひお問い合わせフォームからお聞かせください。\n\n")
                            
                            Text("ClearLayerとともに、\nあなたの学びをもっとスマートに。")
                                .font(.body)
                                .bold()
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal)
                            
                        }
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                    )
        )
    ]

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(0..<tutorialPages.count, id: \.self) { index in
                    VStack(spacing: 20) {
                        Spacer()

                        Text(tutorialPages[index].title)
                            .font(.title2)
                            .bold()

                        tutorialPages[index].descriptionView

                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // ← デフォルトのページインジケーターを非表示にしてカスタムで追加

            HStack(spacing: 8) {
                ForEach(0..<tutorialPages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 16)

            // ✅ ボタンの外観は固定、内容だけ変える
            Button(action: {
                if currentPage == tutorialPages.count - 1 {
                    activeSheet = nil // チュートリアルを閉じる
                }
            }) {
                Text(currentPage == tutorialPages.count - 1 ? "使い始める" : "スワイプして次へ →")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(currentPage == tutorialPages.count - 1 ? Color.accentColor : Color.gray.opacity(0.2))
                    .foregroundColor(currentPage == tutorialPages.count - 1 ? .white : .gray)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding(.bottom, 20)
            .disabled(currentPage != tutorialPages.count - 1)
        }
        .onDisappear {
            // 少しだけ遅延して、完全にモーダルが消えてからATTを出す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onFinished()
            }
        }
    }
}

struct TutorialPage {
    let title: String
    let descriptionView: AnyView
}

struct TutorialSlide: View {
    let title: String
    let description: String
    let imageName: String

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                .foregroundColor(.white)

            Text(title)
                .font(.title)
                .foregroundColor(.white)

            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}

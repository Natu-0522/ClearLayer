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

    let tutorialPages = [
        TutorialPage(
            title: "ClearLayerへようこそ",
            description: """
        ご利用ありがとうございます！

        このアプリは、YouTube動画やWebページの上に  
        透明な紙（レイヤー）を重ね  
        直接文字や線を書き込めるようにした
        学習・作業サポートツールです。
        """
        ),
        TutorialPage(
            title: "ツールボックスについて",
            description: """
        画面右下にあるアイコンが
        ツールボックスです。

        色や太さの変更、ペン・消しゴムの切り替え、
        レイヤー表示の切り替えなどが可能です。
        """
        ),
        TutorialPage(
            title: "設定とご意見について",
            description: """
        画面左上の「︙」から設定画面を開けます。

        ご意見や「こんな機能が欲しい」など、  
        ぜひお問い合わせフォームからお聞かせください。

        ClearLayerとともに、  
        あなたの学びをもっとスマートに。
        """
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

                        Text(tutorialPages[index].description)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

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
    }
}

struct TutorialPage {
    let title: String
    let description: String
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

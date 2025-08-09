//
//  BannerPlaceForAd.swift
//  ClearLayer
//
//  Created by 中里祐希 on 2025/07/18.
//

import SwiftUI
import GoogleMobileAds

/// SwiftUIから使えるバナー広告ビュー
struct BannerAdView: UIViewRepresentable {
    // バナー広告ビューの作成
    func makeUIView(context: Context) -> UIView {
        // ✅ Adaptiveサイズのバナーを画面幅に合わせて作成
        let adSize = currentOrientationAnchoredAdaptiveBanner(width: UIScreen.main.bounds.width)
        let bannerView = BannerView(adSize: adSize)

        // ✅ Ad Unit ID を設定（必須）
        bannerView.adUnitID = Constants.shared.bannerAdUnitID

        // ✅ 表示元のViewControllerを設定
        bannerView.rootViewController = UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController

        // ✅ 広告を読み込む
        bannerView.load(Request())

        // 高さ制約を加えるためのコンテナビュー
        let container = UIView()
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(bannerView)

        // 高さを明示的に制約（推奨：50〜100ptあたり）
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            bannerView.topAnchor.constraint(equalTo: container.topAnchor),
            bannerView.widthAnchor.constraint(equalToConstant: adSize.size.width),
            bannerView.heightAnchor.constraint(equalToConstant: adSize.size.height)
        ])

        return container
    }

    // デバイス回転時などに呼ばれて広告サイズを再設定
    func updateUIView(_ uiView: UIView, context: Context) {
        if let bannerView = uiView.subviews.first as? BannerView {
            let newSize = currentOrientationAnchoredAdaptiveBanner(width: UIScreen.main.bounds.width)
            if bannerView.adSize.size.width != newSize.size.width {
                bannerView.adSize = newSize
                bannerView.load(Request())
            }
        }
    }
}

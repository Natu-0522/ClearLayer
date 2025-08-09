//
//  Constants.swift
//  ClearLayer
//
//  Created by 中里祐希 on 2025/08/10.
//

import Foundation
import GoogleMobileAds

/// 広告の動作モード
enum AdMode { case test, prod }

final class Constants {
    static let shared = Constants()
    private init() {}

    // ========= ここだけ切り替える =========
    // TestFlight 承認を通すとき → .prod
    // ふだんの開発/検証       → .test
    let adMode: AdMode = .test
    // ====================================

    /// Google 公式のテスト用ユニットID（安全）
    private struct TestAdUnit {
        static let banner   = "ca-app-pub-3940256099942544/2934735716"
        static let rewarded = "ca-app-pub-3940256099942544/5224354917"
    }

    /// あなたの本番ユニットID
    private struct ProdAdUnit {
        static let banner   = "ca-app-pub-8866672716864480/9063026208"
        static let rewarded = "ca-app-pub-8866672716864480/5675133898"
    }

    // 公開プロパティ（モードで自動切替）
    var bannerAdUnitID: String {
        adMode == .prod ? ProdAdUnit.banner : TestAdUnit.banner
    }
    var rewardedAdUnitID: String {
        adMode == .prod ? ProdAdUnit.rewarded : TestAdUnit.rewarded
    }
}

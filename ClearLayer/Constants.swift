//
//  Constants.swift
//  ClearLayer
//
//  Created by 中里祐希 on 2025/08/10.
//

import Foundation
import Foundation
import GoogleMobileAds

// 環境判定
enum BuildEnvironment {
    case debug, testFlight, release

    static var current: BuildEnvironment {
        #if DEBUG
        return .debug
        #else
        // StoreKit receipt が "sandboxReceipt" なら TestFlight or 開発配布
        if let url = Bundle.main.appStoreReceiptURL?.lastPathComponent,
           url == "sandboxReceipt" {
            return .testFlight
        } else {
            return .release
        }
        #endif
    }
}

final class Constants {
    static let shared = Constants()
    private init() {}

    // Google公式のテスト用ユニットID（安全）
    private struct TestAdUnit {
        static let banner   = "ca-app-pub-3940256099942544/2934735716"
        static let rewarded = "ca-app-pub-3940256099942544/5224354917"
    }

    // ★本番ユニットID（あなたのIDに置き換え）
    private struct ProdAdUnit {
        static let banner   = "ca-app-pub-8866672716864480/9063026208" // ← バナー
        static let rewarded = "ca-app-pub-8866672716864480/5675133898" // ← リワード（今のやつ）
    }

    // 露出用プロパティ（環境に応じて自動切替）
    var bannerAdUnitID: String {
        switch BuildEnvironment.current {
        case .debug, .testFlight:
            return TestAdUnit.banner
        case .release:
            return ProdAdUnit.banner
        }
    }

    var rewardedAdUnitID: String {
        switch BuildEnvironment.current {
        case .debug, .testFlight:
            return TestAdUnit.rewarded
        case .release:
            return ProdAdUnit.rewarded
        }
    }
}

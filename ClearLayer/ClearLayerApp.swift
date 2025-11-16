//
//  ClearLayerApp.swift
//  ClearLayer
//
//  Created by 中里祐希 on 2025/05/20.
//

//  ClearLayerApp.swift
import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

@main
struct ClearLayerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene { WindowGroup { ContentView() } }
}

// AppDelegateは何もしない（ATT/AdMobはチュートリアル経由のみ）
final class AppDelegate: NSObject, UIApplicationDelegate { }

// ===== 唯一の入口：チュートリアルを閉じた直後に呼ぶ =====
private var didStartAds = false

func requestATTThenStartAds() {
    if #available(iOS 14, *) {
        let status = ATTrackingManager.trackingAuthorizationStatus
        // 既に選択済みなら即AdMob初期化
        guard status == .notDetermined else { startAdsIfNeeded(); return }

        // モーダルが消え切って前面が安定するまで少し待つ
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            ATTrackingManager.requestTrackingAuthorization { _ in
                DispatchQueue.main.async { startAdsIfNeeded() }
            }
        }
    } else {
        startAdsIfNeeded()
    }
}

private func startAdsIfNeeded() {
    guard !didStartAds else { return }
    didStartAds = true
    MobileAds.shared.start { _ in
        UserDefaults.standard.set(true, forKey: "adsReady")   // ← 追加
    }
    print("AdMob started")
}

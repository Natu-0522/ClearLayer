//
//  SettingModel.swift
//  ClearLayer
//
//  Created by 中里祐希 on 2025/08/10.
//

import Foundation
import SwiftUI
import GoogleMobileAds
import Combine
import UIKit

class SettingModel: NSObject, ObservableObject, FullScreenContentDelegate {
    // カラーパレット
    @Published var paletteColors: [String] = [
        "#000000", "#FF0000", "#00FF00", "#0000FF", "#FFFF00", "#FF00FF", "#00FFFF"
    ]

    // ジェスチャ解放状態
    @AppStorage("gestureUnlockUntil") private var gestureUnlockUntil: Double = 0
    @AppStorage("useDoubleTapGesture") var useDoubleTapGesture: Bool = false
    @AppStorage("useTripleTapGesture") var useTripleTapGesture: Bool = false
    var isGestureUnlocked: Bool { Date().timeIntervalSince1970 < gestureUnlockUntil }

    // 残時間表示用（毎秒更新）
    @Published private(set) var now = Date()
    private var timer: AnyCancellable?

    // リワード広告
    @Published var isRewardAdReady: Bool = false
    private var rewardedAd: RewardedAd?

    // 連打対策（最短60秒）
    @AppStorage("lastRewardTime") private var lastRewardTime: Double = 0
    var canRequestReward: Bool { Date().timeIntervalSince1970 - lastRewardTime > 60 }

    override init() {
        super.init()
        loadRewardAd()
        // 1秒刻みで now を更新（View側にタイマー不要）
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] in self?.now = $0 }
    }

    deinit { timer?.cancel() }

    var remainingTimeText: String {
        let remain = gestureUnlockUntil - now.timeIntervalSince1970
        if remain <= 0 { return "ロックされています" }
        let m = Int(remain) / 60, s = Int(remain) % 60
        return String(format: "あと %02d:%02d", m, s)
    }

    func unlockForOneHour() {
        gestureUnlockUntil = Date().addingTimeInterval(3600).timeIntervalSince1970
    }

    func updateUnlockStatusIfNeeded() {
        if !isGestureUnlocked {
            useDoubleTapGesture = false
            useTripleTapGesture = false
            UserDefaults.standard.set(false, forKey: "toolToggle")
            UserDefaults.standard.set(false, forKey: "screenshotToggle")
        }
    }

    // MARK: - Ads
    func loadRewardAd() {
        let request = Request()
        RewardedAd.load(with: Constants.shared.rewardedAdUnitID, request: request) { [weak self] ad, _ in
            DispatchQueue.main.async {
                self?.rewardedAd = ad
                self?.rewardedAd?.fullScreenContentDelegate = self
                self?.isRewardAdReady = (ad != nil)
            }
        }
    }

    func showRewardAd(from rootVC: UIViewController) {
        guard canRequestReward, let ad = rewardedAd else {
            // 無し or 連打ガード中
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return
        }
        ad.present(from: rootVC) { [weak self] in
            guard let self else { return }
            self.lastRewardTime = Date().timeIntervalSince1970
            self.unlockForOneHour()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        loadRewardAd()
    }
}

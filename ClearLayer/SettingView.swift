//
//  SettingView.swift
//  ClearLayer
//
//  Created by 中里祐希 on 2025/07/21.
//

import SwiftUI
import GoogleMobileAds
import StoreKit

// MARK: - 設定画面
struct SettingsView: View {
    @StateObject var settings = SettingModel()
    @ObservedObject var webVM: WebViewModel
    @ObservedObject var drawVM: DrawingViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var activeSheet: ActiveSheet?
//    @Binding var isTutorialPresented: Bool

    var body: some View {
        // 上部バー
        HStack {
            Label("設定", systemImage: "gearshape.fill")
                .font(.title2.bold())
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.top, 20)
        .padding(.horizontal)

        Form {
            Section(header: Text("ブラウザモード")) {
                HStack {
                    Text("現在のブラウザモード")
                        .foregroundColor(.primary)
                    Spacer()
                    Picker("", selection: $drawVM.mode) {
                        Text("YouTube").tag("youtube")
                        Text("Google").tag("browser")
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
                        activeSheet = nil // 設定画面を閉じる
                    }
                }
            }

            Section(header: Text("おためし機能")) {
                Toggle("ダブルタップでツール切替", isOn: $settings.useDoubleTapGesture)
                    .disabled(!settings.isGestureUnlocked)
                    .foregroundColor(settings.isGestureUnlocked ? .primary : .gray)

                Toggle("トリプルタップでスクショ", isOn: $settings.useTripleTapGesture)
                    .disabled(!settings.isGestureUnlocked)
                    .foregroundColor(settings.isGestureUnlocked ? .primary : .gray)
                if settings.isGestureUnlocked {
                    Text(settings.remainingTimeText)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                } else {
                    Button("広告視聴でおためし機能をつかう(1時間)") {
                        print("🔘 ボタンタップ")
                        settings.loadRewardAd()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first(where: { $0.isKeyWindow }),
                               let rootVC = window.rootViewController?.topMostViewController() {

                                settings.showRewardAd(from: rootVC)
                            } else {
                                print("❌ rootViewController の取得に失敗しました")
                            }
                        }
                    }
                }
            }
            .onAppear {
                settings.loadRewardAd()
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                        settings.objectWillChange.send()
                    }
                settings.updateUnlockStatusIfNeeded()
            }
            
            Button("チュートリアルを再度見る") {
                activeSheet = ActiveSheet.tutorial
            }

            Section(header: Text("お問い合わせ")) {
                Link("お問い合わせフォームはこちら", destination: URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSfdipzq4W-EEVMZAZ3U08hB3ucyinrNjNLU8hH2Bt1GOa5TRQ/viewform?usp=header")!)
                    .foregroundColor(.blue)
                Button("プライバシーポリシーを読む") {
                    activeSheet = .privacy
                }
            }
            
            Section(header: Text("このアプリを応援する")) {
                Button("アプリを評価する") {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        if #available(iOS 18.0, *) {
                            AppStore.requestReview(in: windowScene)
                        } else {
                            SKStoreReviewController.requestReview(in: windowScene)
                        }
                    }
                }

                ShareLink(item: URL(string: "https://apps.apple.com/app/idYOUR_APP_ID")!) {
                    Label("このアプリを共有する", systemImage: "square.and.arrow.up")
                }
            }

            Section(header: Text("アプリ情報")) {
                Text("バージョン: 1.0.0")
                Text("© 2025 ClearLayer")
            }
        }
    }
    
}

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        if let nav = self as? UINavigationController {
            return nav.visibleViewController?.topMostViewController() ?? nav
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        return self
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        default:
            r = 0; g = 0; b = 0
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}

// MARK: - 設定情報を保持するモデル
class SettingModel: NSObject, ObservableObject, FullScreenContentDelegate {
    /// パレットに表示する色のリスト（16進カラー文字列）
    @Published var paletteColors: [String] = [
        "#000000", "#FF0000", "#00FF00", "#0000FF", "#FFFF00", "#FF00FF", "#00FFFF"
    ]

    /// ジェスチャ機能の解放済みフラグ
    @AppStorage("gestureUnlockUntil") private var gestureUnlockUntil: Double = 0
    @AppStorage("useDoubleTapGesture") var useDoubleTapGesture: Bool = false
    @AppStorage("useTripleTapGesture") var useTripleTapGesture: Bool = false
    @Published var isRewardAdReady: Bool = false
    private var rewardedAd: RewardedAd?

    var isGestureUnlocked: Bool {
        Date().timeIntervalSince1970 < gestureUnlockUntil
    }
    
    var remainingTimeText: String {
        let remaining = gestureUnlockUntil - Date().timeIntervalSince1970
        if remaining <= 0 {
            return "ロックされています"
        } else {
            let minutes = Int(remaining) / 60
            let seconds = Int(remaining) % 60
            return String(format: "あと %02d:%02d", minutes, seconds)
        }
    }

    func unlockForOneHour() {
        gestureUnlockUntil = Date().addingTimeInterval(3600).timeIntervalSince1970
    }
    func updateUnlockStatusIfNeeded() {
        if !isGestureUnlocked {
            print("⏱ 時間切れ。トグルをリセットします")
            useDoubleTapGesture = false
            useTripleTapGesture = false
            UserDefaults.standard.set(false, forKey: "toolToggle")
            UserDefaults.standard.set(false, forKey: "screenshotToggle")
        }
    }

    override init() {
        super.init()
        loadRewardAd()
    }

    func loadRewardAd() {
        let request = Request()
        RewardedAd.load(with: "ca-app-pub-8866672716864480/5675133898", request: request) { ad, error in
            if let ad = ad {
                self.rewardedAd = ad
                ad.fullScreenContentDelegate = self
                DispatchQueue.main.async {
                    self.isRewardAdReady = true
//                    print("✅ 広告ロード完了")
                }
            } else {
//                print("❌ 広告ロード失敗: \(error?.localizedDescription ?? "不明なエラー")")
                DispatchQueue.main.async {
                    self.isRewardAdReady = false
                }
            }
        }
    }

    func showRewardAd(from rootViewController: UIViewController) {
        print("showRewardAd called")

        guard let ad = rewardedAd else {
//            print("❌ rewardedAd is nil!")
            return
        }

        ad.present(from: rootViewController) {
//            print("🎉 報酬発生")
            self.unlockForOneHour()
        }
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
//        print("🔄 広告閉じたので再読み込み")
        loadRewardAd()
    }
    
    
}


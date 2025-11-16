import SwiftUI
import GoogleMobileAds
import StoreKit

struct SettingsView: View {
    @StateObject var settings = SettingModel()
    @ObservedObject var webVM: WebViewModel
    @ObservedObject var drawVM: DrawingViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var activeSheet: ActiveSheet?

    @State private var showAdLoadingAlert = false
    @State private var showUnlockedToast = false
    @State private var wasUnlocked = false

    var body: some View {
        VStack(spacing: 0) {
            // 上部バー
            HStack {
                Label("設定", systemImage: "gearshape.fill")
                    .font(.title2.bold())
                Spacer()
            }
            .padding(.top, 20)
            .padding(.horizontal)

            Form {
                // 起動時表示
                Section(header: Text("表示モード")) {
                    HStack {
                        Text("現在のモード")
                        Spacer()
                        Picker("", selection: $drawVM.mode) {
                            Text("YouTube").tag("youtube")
                            Text("ブラウザ").tag("browser")
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 150)
                        .onChange(of: drawVM.mode) {
                            let newURL = URL(string: drawVM.mode == "youtube" ? "https://www.youtube.com" : "https://www.google.com")!
                            drawVM.currentURL = newURL
                            drawVM.urlString = newURL.absoluteString
                            drawVM.showDrawing = false
                            webVM.load(newURL)
                            withAnimation { drawVM.showModeText = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation { drawVM.showModeText = false }
                            }
                            // activeSheet = nil  // 自動で閉じたくないならコメントアウトのままでOK
                        }
                    }
                }

                // ジェスチャ（おためし）
                Section(
                    header: Text("ジェスチャー（おためし）"),
                    footer:
                        Text(settings.isGestureUnlocked
                             ? "残り時間：\(settings.remainingTimeText)"
                             : "広告を視聴すると1時間だけジェスチャー機能を試せます。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                ) {
                    Toggle("ダブルタップでツール切替", isOn: $settings.useDoubleTapGesture)
                        .disabled(!settings.isGestureUnlocked)
                        .accessibilityHint(
                            Text(settings.isGestureUnlocked
                                 ? "有効にするとダブルタップで切替が可能です"
                                 : "広告視聴で1時間だけ有効化できます")
                        )

                    Toggle("トリプルタップでスクショ", isOn: $settings.useTripleTapGesture)
                        .disabled(!settings.isGestureUnlocked)

                    if !settings.isGestureUnlocked {
                        Button(settings.isRewardAdReady ? "広告視聴でおためし機能を使えるようにする（1時間）"
                                                        : "広告を準備中…") {
                            if settings.isRewardAdReady {
                                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let window = scene.windows.first(where: { $0.isKeyWindow }),
                                   let rootVC = window.rootViewController?.topMostViewController() {
                                    settings.showRewardAd(from: rootVC)
                                }
                            } else {
                                showAdLoadingAlert = true
                                settings.loadRewardAd()
                                UINotificationFeedbackGenerator().notificationOccurred(.warning)
                            }
                        }
                        .opacity(settings.isRewardAdReady ? 1 : 0.7)
                        .alert("広告を準備中です", isPresented: $showAdLoadingAlert) {
                            Button("OK", role: .cancel) {}
                        } message: {
                            Text("数秒後にもう一度お試しください。")
                        }
                        .accessibilityHint(Text("広告を視聴すると1時間だけジェスチャー機能が有効になります"))
                    }
                }
                .onAppear {
                    settings.loadRewardAd()
                    settings.updateUnlockStatusIfNeeded()
                }

                // チュートリアル
                Button("チュートリアルを再度見る") {
                    activeSheet = .tutorial
                }

                // 問い合わせ
                Section(header: Text("お問い合わせ")) {
                    Link("お問い合わせフォームを開く",
                         destination: URL(string: String(localized: "https://docs.google.com/forms/d/e/1FAIpQLSfdipzq4W-EEVMZAZ3U08hB3ucyinrNjNLU8hH2Bt1GOa5TRQ/viewform?usp=header"))!)
                    Link("プライバシーポリシーを開く",
                         destination: URL(string: String(localized: "https://sites.google.com/view/clearlayer/%E3%83%9B%E3%83%BC%E3%83%A0"))!)
                }

                // 応援
                Section(header: Text("このアプリを応援する")) {
                    // 評価する
                    Button {
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            if #available(iOS 18.0, *) { AppStore.requestReview(in: scene) }
                            else { SKStoreReviewController.requestReview(in: scene) }
                        }
                    } label: {
                        HStack {
                            Label("アプリを評価する", systemImage: "star.fill")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .tint(.primary)

                    // 共有する
                    ShareLink(item: URL(string: "https://apps.apple.com/app/idYOUR_APP_ID")!) {
                        HStack {
                            Label("このアプリを共有する", systemImage: "square.and.arrow.up")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .tint(.primary)
                }

                // 情報
                Section(header: Text("アプリ情報")) {
                    Text("バージョン: \(Bundle.main.appVersion)")
                    Text("© 2025 ClearLayer")
                }
            }
        }
        // 解放トースト
        .overlay(alignment: .top) {
            if showUnlockedToast {
                Text("ジェスチャーを1時間解放しました")
                    .font(.caption)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .transition(.opacity)
                    .padding(.top, 8)
            }
        }
        // 解放状態の変化でトースト＆ハプティクス
        .onChange(of: settings.isGestureUnlocked) { oldValue, newValue in
            if newValue && !wasUnlocked {
                wasUnlocked = true
                showUnlockedToast = true
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { showUnlockedToast = false }
                }
            }
            if !newValue { wasUnlocked = false }
        }
    }
}

// 既存の topMostViewController(), Color(hex:) はそのままでOK
extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let p = presentedViewController { return p.topMostViewController() }
        if let n = self as? UINavigationController { return n.visibleViewController?.topMostViewController() ?? n }
        if let t = self as? UITabBarController { return t.selectedViewController?.topMostViewController() ?? t }
        return self
    }
}

//
//  DrawingViewModel.swift
//  ClearLayer
//
//  Created by 中里祐希 on 2025/07/14.
//
import SwiftUI
import UIKit
import Combine

/// お絵かきレイヤーの状態と操作をまとめた ViewModel
final class DrawingViewModel: ObservableObject {
    @Published var lines: [Line] = [] // 描画されたすべての線のリスト
    @Published var currentLine = Line(points: [], color: .black, width: 3) // 現在描いている途中の線

    @Published var isEraserOn: Bool = false // 消しゴムモードかどうか
    @Published var clearCanvas: Bool = false // 全消去トリガー（trueでキャンバスをクリア）
    @Published var showDrawing: Bool = false // 描画レイヤーを表示するかどうか
    @Published var triggerSweepEffect = false // スイープアニメーションのトリガー
    @Published var currentURL: URL = URL(string: "https://www.youtube.com")! // 現在表示中のWebページのURL
    @Published var showModeText: Bool = false // モード名（YouTubeなど）を一時的に表示するか
    @Published var isEditingURL = false // URL欄を編集中かどうか
    @Published var didTakeScreenshot: Bool = false // スクショを撮った直後にtrue（トースト表示などに使用）
    @Published var selectedColor: Color = .black  // 現在選択中の色

    @AppStorage("lineWidth") private var lineWidthRaw: Double = 3 // 線の太さ（永続保存）
    var lineWidth: CGFloat {
        get { CGFloat(lineWidthRaw) }
        set { lineWidthRaw = Double(newValue) }
    }
    

    @AppStorage("isFullToolboxVisible") var isFullToolboxVisible: Bool = false // ツールUIを展開状態にするか
    @AppStorage("mode") var mode: String = "youtube" // 動作モード（"youtube"など）
    @AppStorage("urlString") var urlString: String = "https://www.youtube.com" // 入力されたURLの文字列（永続化）

    private var previousColor: Color = .black // 消しゴムから元に戻す時のための元の色保持

    struct Line {
        var points: [CGPoint] // 線を構成する点の配列
        var color: Color // 線の色
        var width: CGFloat // 線の太さ
    }

    /// 消しゴムモードのトグル
    func toggleEraser() {
        if isEraserOn {
            // 消しゴムオフ → 元の色に戻す
            selectedColor = previousColor
            isEraserOn = false
        } else {
            // 消しゴムオン → 現在色を退避してクリアに
            previousColor = selectedColor
            selectedColor = .clear
            isEraserOn = true
        }
    }

    /// 指定数分の線を削除（Undo風の処理）
    func deleteGestureTap(at index: Int) {
        if lines.count >= index {
            lines.removeLast(index)
        }
    }

    /// スクリーンショットを撮影してフォトライブラリに保存する
    func takeScreenshot() {
        guard
            let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
            let window = windowScene.windows.first(where: { $0.isKeyWindow })
        else {
            return
        }
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        let image = renderer.image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        didTakeScreenshot = true
    }
}

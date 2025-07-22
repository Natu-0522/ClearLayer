//
//  SweepEffectView.swift
//  ClearLayer
//
//  Created by 中里祐希 on 2025/07/22.
//

import SwiftUI

struct SweepEffectView: View {
    // エフェクトの表示状態を制御（falseで非表示）
    @Binding var isActive: Bool
    // エフェクトのオフセット位置（アニメーション用）
    @Binding var sweepOffset: CGSize
    
    // trueなら「描画ON」、falseなら「描画OFF」の切り替えエフェクト
    var isTurningOn: Bool

    var body: some View {
        // エフェクトの見た目（薄い青色の斜め長方形）
        Color(red: 0.88, green: 0.95, blue: 1.0).opacity(0.5)
            .frame(
                width: 100,
                height: UIScreen.main.bounds.height * 2 // 画面より縦長で斜めにカバー
            )
            .rotationEffect(.degrees(45)) // 斜め45度に回転
            .offset(sweepOffset) // 現在の位置（アニメーション用）
            .zIndex(100) // 最前面に表示
            .onAppear {
                // アニメーション開始時の初期位置を設定
                sweepOffset = isTurningOn
                    ? CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    : CGSize(width: -UIScreen.main.bounds.width * 1.5,
                             height: -UIScreen.main.bounds.height * 1.5)

                // アニメーションで逆方向にスイープさせる
                withAnimation(.easeOut(duration: 0.8)) {
                    sweepOffset = isTurningOn
                        ? CGSize(width: -UIScreen.main.bounds.width * 1.5,
                                 height: -UIScreen.main.bounds.height * 1.5)
                        : CGSize(width: UIScreen.main.bounds.width,
                                 height: UIScreen.main.bounds.height)
                }

                // 少し待ってからエフェクトを非表示に（パフォーマンスや再表示制御のため）
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isActive = false
                }
            }
    }
}

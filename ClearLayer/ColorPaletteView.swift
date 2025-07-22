//
//  ColorPaletteView.swift
//  ClearLayer
//
//  Created by 中里祐希 on 2025/07/17.
//

import SwiftUI

/// メインアイコンの上に水平に並んだ色選択パレットを表示するビュー
struct ColorPaletteView: View {
    /// パレットの表示／非表示を切り替えるフラグ
    @Binding var isPresented: Bool
    /// 選択中の色
    @Binding var selectedColor: Color

    /// パレットに並べる色のリスト
    let colors: [Color] = [.black, .red, .blue, .yellow.opacity(0.5), .pink.opacity(0.5)]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(colors.indices, id: \.self) { index in
                let color = colors[index]
                let isHighlighter = index >= colors.count - 2

                Button {
                    // 色を選んだら閉じる
                    selectedColor = color
                    withAnimation { isPresented = false }
                } label: {
                    ZStack {
                        Circle()
                            .fill(color)
                            .frame(width: 28, height: 28)

                        if isHighlighter {
                            Circle()
                                .stroke(Color.white, lineWidth: 1)
                                .overlay(
                                    Image(systemName: "highlighter")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 12, height: 12)
                                        .foregroundColor(.white)
                                )
                        }

                        Circle()
                            .stroke(Color.white, lineWidth: selectedColor == color ? 2 : 0)
                    }
                }
            }
        }
        .padding(6)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

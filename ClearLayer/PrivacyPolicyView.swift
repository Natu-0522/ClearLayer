//
//  PrivacyPolicyView.swift
//  ClearLayer
//
//  Created by 中里祐希 on 2025/07/23.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("プライバシーポリシー")
                        .font(.title2)
                        .bold()

                    Text("ClearLayer（以下、「本アプリ」）は、ユーザーのプライバシーを尊重し、個人情報の保護に努めています。本ポリシーでは、本アプリが収集する情報、利用目的、第三者への提供などについて説明します。")

                    Group {
                        Text("1. 収集する情報")
                            .bold()
                        Text("本アプリでは、次の情報を収集することがあります：")
                        Text("・クラッシュログ、利用状況などの匿名データ（アプリ改善のため）")
                        Text("・広告配信のための識別子（Google AdMob）")

                        Text("2. 情報の利用目的")
                            .bold()
                        Text("・アプリの品質向上のため\n・ユーザーサポートのため\n・広告の最適化のため")

                        Text("3. 第三者への提供")
                            .bold()
                        Text("収集した情報は、以下のサービスに共有されることがあります：\n・Google AdMob（広告配信）")

                        Text("4. お問い合わせ")
                            .bold()
                        Text("ご不明点やご意見がある場合は、アプリ内の設定画面からお問い合わせフォームをご利用ください。")

                        Text("5. 改定")
                            .bold()
                        Text("本ポリシーは必要に応じて変更されることがあります。最新版はアプリ内またはWeb上でご確認いただけます。")
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("プライバシーポリシー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PrivacyPolicyView()
}

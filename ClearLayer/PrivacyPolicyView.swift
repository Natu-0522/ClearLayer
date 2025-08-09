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
                        .font(.title2).bold()

                    Text("ClearLayer（以下「本アプリ」）は、ユーザーのプライバシーを尊重し、個人情報の保護に努めます。本ポリシーは、本アプリで取り扱う情報の種別、利用目的、第三者提供、ユーザーの選択肢等を定めるものです。")

                    Group {
                        Text("1. 収集する情報").bold()
                        Text("""
                        本アプリ自体は会員登録や氏名・メールアドレス等の個人情報を収集しません。主に以下の情報が端末上または第三者SDKにより取り扱われる場合があります。
                        ・広告配信用識別子（IDFA）およびおおよその位置情報、デバイス情報（モデル、OS等）
                        ・診断/クラッシュログ等の匿名統計情報（品質向上のため）
                        ・お問い合わせ時にご記入いただいた内容（ユーザーサポートのため）
                        """)

                        Text("2. 利用目的").bold()
                        Text("① アプリの機能提供と品質改善  ② 問い合わせ対応  ③ 広告配信およびその最適化")

                        Text("3. 第三者への提供等").bold()
                        Text("""
                        広告配信に Google AdMob を利用します。AdMob は前項の範囲で広告配信に必要なデータを取得・利用する場合があります。詳細はGoogleのプライバシーポリシーおよびAdMobのポリシーをご確認ください。
                        共同利用は行いません。
                        """)

                        Text("4. 追跡の許可（ATT）と同意管理").bold()
                        Text("""
                        本アプリは広告最適化のため、iOSの「トラッキングの許可」を求めることがあります。許可/不許可は端末の「設定 > プライバシーとセキュリティ > 追跡」からいつでも変更できます。欧州経済領域等では、同意管理（UMP）により広告のパーソナライズ可否を選択できます。
                        """)

                        Text("5. 保存期間と削除").bold()
                        Text("""
                        本アプリが端末内に保存するデータは、機能提供に必要な期間保持します。広告関連のデータや診断情報の保存・管理は各事業者のポリシーに従います。IDFAは端末の設定からリセット可能です。
                        """)

                        Text("6. お問い合わせ").bold()
                        Text("ご不明点は、アプリ内「設定 > お問い合わせ」からフォームにてご連絡ください。")

                        Text("7. 改定").bold()
                        Text("本ポリシーは予告なく改定されることがあります。改定後はアプリ内に掲載した時点で効力を生じます。")

                        Text("施行日：2025年8月9日").font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding()            }
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

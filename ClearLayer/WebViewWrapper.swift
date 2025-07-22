////  WebViewWrapper.swift
////  ClearLayer
////
////  Created by 中里祐希 on 2025/05/20.


import SwiftUI
import WebKit

struct WebViewWrapper: UIViewRepresentable {
    @ObservedObject var viewModel: WebViewModel

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        // モデルに紐づけてロード＆KVO開始
        viewModel.attach(to: webView)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {

    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: ()) {

    }
}

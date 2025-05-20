//
//  WebViewWrapper.swift
//  ClearLayer
//
//  Created by 中里祐希 on 2025/05/20.
//

import SwiftUI
import WebKit

struct WebViewWrapper: UIViewRepresentable {
    let url: URL
    @Binding var webView: WKWebView?

    class Coordinator {
        var lastLoadedURL: URL?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let view = WKWebView(frame: .zero, configuration: config)
        view.load(URLRequest(url: url))
        context.coordinator.lastLoadedURL = url

        DispatchQueue.main.async {
            self.webView = view
        }
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // ✅ URLが変わったときだけ読み込み直す
        if context.coordinator.lastLoadedURL != url {
            uiView.load(URLRequest(url: url))
            context.coordinator.lastLoadedURL = url
        }
    }
}

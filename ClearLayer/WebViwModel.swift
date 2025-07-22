import SwiftUI
import WebKit
import Combine

/// KVO で WKWebView の状態を監視する ViewModel
final class WebViewModel: NSObject, ObservableObject {
    // MARK: Published Properties
    @Published var url: URL
    @Published var pageTitle: String = ""
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var isLayerOn: Bool = false

    private var webView: WKWebView?
    private static var kvoContext = 0

    init(initialURL: URL) {
        self.url = initialURL
        super.init()
    }

    deinit {
        detachObservers()
    }

    /// WKWebView をセットして監視開始
    func attach(to webView: WKWebView) {
        self.webView = webView
        webView.load(URLRequest(url: url))

        webView.addObserver(self,
                    forKeyPath: #keyPath(WKWebView.url),
                    options: [.new],
                    context: &WebViewModel.kvoContext)
        webView.addObserver(self,
                    forKeyPath: #keyPath(WKWebView.title),
                    options: [.new],
                    context: &WebViewModel.kvoContext)
        webView.addObserver(self,
                    forKeyPath: #keyPath(WKWebView.canGoBack),
                    options: [.new],
                    context: &WebViewModel.kvoContext)
        webView.addObserver(self,
                    forKeyPath: #keyPath(WKWebView.canGoForward),
                    options: [.new],
                    context: &WebViewModel.kvoContext)
    }

    /// 再読み込み
    func reload() { webView?.reload() }

    /// 戻る
    func goBack() { webView?.goBack() }

    /// 進む
    func goForward() { webView?.goForward() }

    /// URL をプログラムから変更
    func load(_ newURL: URL) {
        url = newURL
        webView?.load(URLRequest(url: newURL))
    }
    
    /// YouTube の video 要素を play/pause する
    func togglePlayPause() {
        let js = """
        var video = document.querySelector('video');
        if (video) {
            if (video.paused) {
                video.play();
            } else {
                video.pause();
            }
        }
        """
        webView?.evaluateJavaScript(js, completionHandler: nil)
    }

    /// KVO の解除
    private func detachObservers() {
        guard let webView = webView else { return }
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.url), context: &WebViewModel.kvoContext)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.title), context: &WebViewModel.kvoContext)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), context: &WebViewModel.kvoContext)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), context: &WebViewModel.kvoContext)
    }

    // MARK: KVO コールバック
    override func observeValue(forKeyPath keyPath: String?,
               of object: Any?,
               change: [NSKeyValueChangeKey : Any]?,
               context: UnsafeMutableRawPointer?) {
            guard context == &WebViewModel.kvoContext,
            let webView = object as? WKWebView else {
                super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
                return
            }

        DispatchQueue.main.async {
            switch keyPath {
                case #keyPath(WKWebView.url):
                    if let newURL = webView.url { self.url = newURL }
                case #keyPath(WKWebView.title):
                    self.pageTitle = webView.title ?? ""
                case #keyPath(WKWebView.canGoBack):
                    self.canGoBack = webView.canGoBack
                case #keyPath(WKWebView.canGoForward):
                    self.canGoForward = webView.canGoForward
                default:
                    break
            }
        }
    }
}

//
//  WebView.swift
//  行程管家 TripMate · WKWebView 壳
//
//  说明：
//  1. 原型是单文件 HTML（CSS/JS 全部内联），这里直接从 App 包内读取 index.html；
//  2. 用 https://tripmate.local/ 作为 baseURL，给页面一个稳定的安全来源，
//     这样 localStorage（登录状态、业务数据）和历史路由才能正常持久化；
//  3. 页面不发起任何网络请求，完全离线运行。
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        config.allowsInlineMediaPlayback = true
        config.defaultWebpagePreferences.allowsContentJavaScript = true

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.bounces = false
        webView.allowsBackForwardNavigationGestures = false

        let fallback = "<html><body style=\"font-family:-apple-system;padding:40px;color:#333\">"
            + "未找到内置页面 index.html，请先运行 tools/build_ios.ps1 生成。</body></html>"
        let html = WebView.loadBundledHTML() ?? fallback

        webView.loadHTMLString(html, baseURL: WebView.baseURL)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    /// 固定来源：保证 localStorage 在 App 重启后仍然存在。
    static let baseURL = URL(string: "https://tripmate.local/")!

    static func loadBundledHTML() -> String? {
        guard let url = Bundle.main.url(forResource: "index", withExtension: "html"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}

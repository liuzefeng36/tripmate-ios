//
//  TripMateApp.swift
//  行程管家 TripMate · iOS 原生壳
//
//  用 WKWebView 加载内置的单文件原型（Resources/index.html），
//  以固定的 https 源加载，保证 localStorage、hash 路由等 Web 能力正常。
//

import SwiftUI

@main
struct TripMateApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}

struct ContentView: View {
    var body: some View {
        WebView()
            .background(Color(red: 0.965, green: 0.976, blue: 0.988))
            .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

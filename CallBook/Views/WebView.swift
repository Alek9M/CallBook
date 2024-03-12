////
////  WebView.swift
////  CallBook
////
////  Created by M on 12/03/2024.
////
//
//import SwiftUI
//import WebKit
//
//struct WebView {
//    var url: URL
//    @Binding var isLoading: Bool
//    @Binding var error: Error?
//    
//    func makeCoordinator() -> WebView.Coordinator {
//        Coordinator(self)
//    }
//    
//    func makeWebView(context: Context) -> WKWebView {
//        let webView = WKWebView()
//        webView.navigationDelegate = context.coordinator
//        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
//        webView.load(request)
//        return webView
//    }
//    
//    class Coordinator: NSObject, WKNavigationDelegate {
//        var parent: PlatformIndependentWebView
//        
//        init(_ uiWebView: PlatformIndependentWebView) {
//            self.parent = uiWebView
//        }
//        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//            parent.isLoading = true
//        }
//        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//            parent.isLoading = false
//        }
//        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//            print("loading error: \(error)")
//            parent.isLoading = false
//            parent.error = error
//        }
//    }
//}
//
//#if os(macOS)
//extension WebView: NSViewRepresentable {
//    func makeNSView(context: Context) -> WKWebView {
//        makeWebView(context: context)
//    }
//    func updateNSView(_ nsView: WKWebView, context: Context) {
//        
//    }
//}
//#else
//extension WebView: UIViewRepresentable {
//    func makeUIView(context: Context) -> WKWebView {
//        makeWebView(context: context)
//    }
//    
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//    }
//}
//#endif

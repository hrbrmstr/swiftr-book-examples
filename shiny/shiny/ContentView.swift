import SwiftUI

struct ContentView: View {
  
  @StateObject var webViewStore = WebViewStore()
  
  var body: some View {
    WebView(webView: webViewStore.webView)
      .frame(width: 900, height: 500, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
      .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
        webViewStore.killit()
      }
  }
  
}

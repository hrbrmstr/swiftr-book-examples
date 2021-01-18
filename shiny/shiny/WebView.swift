import SwiftUI
import Combine
import WebKit

func runApp(_ appPath: String) -> Process {
  
  let task = Process()
  task.environment = ["RAPP_HOME": Bundle.main.bundlePath.appending("/Contents/Frameworks/R.framework/Resources") ]
  task.launchPath = Bundle.main.bundlePath.appending("/Contents/Frameworks/R.framework/Resources/bin/R")
  task.arguments = [
    "--vanilla",
    "--silent",
    "--no-echo",
    "--file=\(appPath)"
  ]
  task.terminationHandler = { _ in
    print("Shiny process terminating")
  }
  task.launch()
  return(task)
  
}

@dynamicMemberLookup
public class WebViewStore: ObservableObject {
  
  @Published public var webView: WKWebView { didSet { setupObservers() } }
  
  private var shinyApp: Process
  
  init(webView: WKWebView = WKWebView()) {
    
    self.webView = webView
    
    let shinyAppPath = Bundle.main.path(forResource: "shiny-app", ofType: "rscript")!
    shinyApp = runApp(shinyAppPath)
    
    self.webView.allowsBackForwardNavigationGestures = false
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
      self.webView.load(URLRequest(url: URL(string: "http://127.0.0.1:11111")!))
    }
    
    setupObservers()
    
  }
  
  func killit() {
    shinyApp.terminate()
  }
  
  deinit {
    shinyApp.terminate()
  }
  
  private func setupObservers() {
    func subscriber<Value>(for keyPath: KeyPath<WKWebView, Value>) -> NSKeyValueObservation {
      return webView.observe(keyPath, options: [.prior]) { _, change in
        if change.isPrior {
          self.objectWillChange.send()
        }
      }
    }
    // Setup observers for all KVO compliant properties
    observers = [
      subscriber(for: \.title),
      subscriber(for: \.url),
      subscriber(for: \.isLoading),
      subscriber(for: \.estimatedProgress),
      subscriber(for: \.hasOnlySecureContent),
      subscriber(for: \.serverTrust),
      subscriber(for: \.canGoBack),
      subscriber(for: \.canGoForward)
    ]
  }
  
  private var observers: [NSKeyValueObservation] = []
  
  public subscript<T>(dynamicMember keyPath: KeyPath<WKWebView, T>) -> T {
    webView[keyPath: keyPath]
  }
  
}

/// A container for using a WKWebView in SwiftUI
public struct WebView: View, NSViewRepresentable {
  /// The WKWebView to display
  public let webView: WKWebView
  
  public init(webView: WKWebView) {
    self.webView = webView
  }
  
  public func makeNSView(context: NSViewRepresentableContext<WebView>) -> WKWebView {
    webView
  }
  
  public func updateNSView(_ uiView: WKWebView, context: NSViewRepresentableContext<WebView>) {
  }
}

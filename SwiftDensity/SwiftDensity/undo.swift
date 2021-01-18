// https://github.com/LostMoa/UndoProviderExample

import Foundation
import SwiftUI

struct Provider<WrappedView>: View where WrappedView: View {
  
  var wrappedView: () -> WrappedView
  
  init(@ViewBuilder wrappedView: @escaping () -> WrappedView) {
    self.wrappedView = wrappedView
  }
  
  var body: some View {
    wrappedView()
  }
}

struct BindingInterceptedProvider<WrappedView, Value>: View where WrappedView: View {
  
  var wrappedView: (Binding<Value>) -> WrappedView
  
  var binding: Binding<Value>
  
  init(
    _ binding: Binding<Value>,
    @ViewBuilder wrappedView: @escaping (Binding<Value>) -> WrappedView
  ) {
    self.binding = binding
    self.wrappedView = wrappedView
  }
  
  var interceptedBinding: Binding<Value> {
    Binding {
      self.binding.wrappedValue
    } set: { newValue in
      print("\(newValue) is about to override \(self.binding.wrappedValue)")
      self.binding.wrappedValue = newValue
    }
  }
  
  var body: some View {
    wrappedView(self.interceptedBinding)
  }
}

struct UndoProvider<WrappedView, Value>: View where WrappedView: View {
  
  @Environment(\.undoManager)
  var undoManager
  
  @StateObject
  var handler: UndoHandler<Value> = UndoHandler()
  
  var wrappedView: (Binding<Value>) -> WrappedView
  
  var binding: Binding<Value>
  
  init(_ binding: Binding<Value>, @ViewBuilder wrappedView: @escaping (Binding<Value>) -> WrappedView) {
    self.binding = binding
    self.wrappedView = wrappedView
  }
  
  var interceptedBinding: Binding<Value> {
    Binding {
      self.binding.wrappedValue
    } set: { newValue in
      self.handler.registerUndo(from: self.binding.wrappedValue, to: newValue)
      self.binding.wrappedValue = newValue
    }
  }
  
  var body: some View {
    wrappedView(self.interceptedBinding).onAppear {
      self.handler.binding = self.binding
      self.handler.undoManger = self.undoManager
    }.onChange(of: self.undoManager) { undoManager in
      self.handler.undoManger = undoManager
    }
  }
}

class UndoHandler<Value>: ObservableObject {
  var binding: Binding<Value>?
  weak var undoManger: UndoManager?
  
  func registerUndo(from oldValue: Value, to newValue: Value) {
    undoManger?.registerUndo(withTarget: self) { handler in
      handler.registerUndo(from: newValue, to: oldValue)
      handler.binding?.wrappedValue = oldValue
    }
  }
  
  init() {}
}


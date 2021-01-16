import SwiftUI

struct ContentView: View {
  
  @State var randomSeed: String = "20210120"
  @State var sampleRangeStart: String = "1"
  @State var sampleRangeEnd: String = "1000"
  @State var sampledValues: String = ""
  
  @ObservedObject var randomApp = RandomModel()
  
  var body: some View {
    HStack {
      VStack(alignment: .trailing) {
        
        HStack {
          Text("Random Seed:")
          TextField("", text: $randomSeed)
            .multilineTextAlignment(.trailing)
            .frame(width: 100)
        }
        
        HStack {
          Text("Range Start:")
          TextField("", text: $sampleRangeStart)
            .multilineTextAlignment(.trailing)
            .frame(width: 100)
        }
        
        HStack {
          Text("Range End:")
          TextField("", text: $sampleRangeEnd)
            .multilineTextAlignment(.trailing)
            .frame(width: 100)
        }
        
        Button("Generate Values", action: {
          sampledValues = randomApp.sample(
            rangeStart: Int(sampleRangeStart) ?? 1,
            rangeEnd: Int(sampleRangeEnd) ?? 100,
            size: 20,
            seed : Int(randomSeed) ?? 20210120
          )
        })
        
      }
      .padding()
          
      VStack {
        TextEditor(text: $sampledValues)
          .padding(4)
          .border(Color.primary)
          .padding()
      }
    }.frame(width: 500, height: 200)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

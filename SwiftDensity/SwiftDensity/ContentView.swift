import SwiftUI

struct ContentView: View {
  
  @ObservedObject var densityApp = DensityModel()

  var body: some View {
    
    VStack {
      
      HStack {
        
        // MARK: Kernel radio buttons
        
        VStack {
          Text(LocalizationStrings.DENSITY_ESTIMATION_KERNEL)
          Picker(selection: $densityApp.kernel, label: Text("")) {
            ForEach(densityApp.availableKernels, id: \.self) { kernel in
              Text(kernel)
            }
          }
          .pickerStyle(RadioGroupPickerStyle())
          .onChange(of: densityApp.kernel, perform: { value in
            densityApp.updatePlot()
          })
        }
        .help(LocalizationStrings.KERNEL_HELP)
        .padding()
        
        // MARK: Kernel bandwidth slider
        
        VStack {
          Group {
            Text("\(LocalizationStrings.DENSITY_ESTIMATION_BANDWIDTH): \(String(densityApp.bandwidth.roundToDecimal(AppGlobals.BANDWIDTH_DISPLAY_DECIMALS)))")
            Slider(
              value: $densityApp.bandwidth,
              in: AppGlobals.BANDWIDTH_RANGE,
              onEditingChanged: { editing in
                if (!editing) { densityApp.updatePlot() }
              }
            )
            .padding()
          }
          .help(LocalizationStrings.BANDWIDTH_HELP)

          Spacer()
          
          // MARK: R data generation script
          
          VStack {
            Text(LocalizationStrings.R_CMD_LABEL)
            Group {
              UndoProvider($densityApp.rCmd) { rCmd in
                TextField(
                  "",
                  text: rCmd,
                  onEditingChanged: { tap in
                    if (!tap) { densityApp.validateRCmd() }
                  },
                  onCommit: {
                    densityApp.validateRCmd()
                    if (densityApp.rCmdOK) { densityApp.updatePlot() }
                  }
                )
                .font(.system(size: 12, design: .monospaced))
                .disableAutocorrection(true)
                .lineLimit(3)
                .padding(4)
              }
            } .border((densityApp.rCmdOK) ? Color.codeOK : Color.codeError)
          }
          .help(LocalizationStrings.RCMD_HELP)
          
        }.padding()
        
      }
      
      Divider()
      
      HStack { // MARK: Plot pane
        Image(nsImage: NSImage(data: densityApp.plotData) ?? NSImage())
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(
            width: AppGlobals.PLOT_WIDTH,
            height: AppGlobals.PLOT_HEIGHT,
            alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/
           )
          .help(LocalizationStrings.PLOT_HELP)
          .focusable()
          .contextMenu(ContextMenu(menuItems: {
            Button(action: {
              NSPasteboard.general.clearContents()
              NSPasteboard.general.writeObjects([ (NSImage(data: densityApp.plotData) ?? NSImage()) ])
            }) {
              Text("Copy")
              Image(systemName: "doc.on.doc")
            }
          }))
          .onCopyCommand(perform: {
            let item = [
              NSItemProvider(
                item: (NSImage(data: densityApp.plotData) ?? NSImage()).tiffRepresentation as NSSecureCoding?,
                typeIdentifier: kUTTypeTIFF as String
              )
            ]
            return(item)
          })
          .border(Color.primary)
      }
      
    }.padding()
    
  }
}

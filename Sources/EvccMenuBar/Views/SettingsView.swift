import SwiftUI

struct SettingsView: View {
    @ObservedObject var evccState: EvccState
    @State private var tempApiUrl: String = ""
    
    var body: some View {
        Form {
            TextField("evcc API URL", text: $tempApiUrl)
                .textFieldStyle(.roundedBorder)
                .onAppear {
                    tempApiUrl = evccState.apiUrl
                }
            
            Button("Save") {
                evccState.updateApiUrl(tempApiUrl)
            }
        }
        .padding()
        .frame(width: 300)
    }
} 
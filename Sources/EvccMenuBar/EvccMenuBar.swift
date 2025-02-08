import SwiftUI
import AppKit

@main
struct EvccMenuBarApp: App {
    @StateObject private var evccState = EvccState()
    
    var body: some Scene {
        MenuBarExtra(content: {
            MenuBarView(evccState: evccState)
        }, label: {
            Image(systemName: evccState.vehicleCharging ? "bolt.car.fill" : "ev.charger.slash")
        })
        .menuBarExtraStyle(.window)
        
        Settings {
            SettingsView(evccState: evccState)
        }
    }
} 
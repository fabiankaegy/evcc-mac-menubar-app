import SwiftUI
import AppKit

@main
struct EvccMenuBarApp: App {
    @StateObject private var evccState = EvccState()
    
    var body: some Scene {
        MenuBarExtra(content: {
            MenuBarView(evccState: evccState)
        }, label: {
            Image(systemName: menuBarIcon)
        })
        .menuBarExtraStyle(.window)
    }
    
    private var menuBarIcon: String {
        if evccState.vehicleCharging {
            return "bolt.car.fill"
        } else if evccState.vehicleConnected {
            return "ev.charger"
        } else {
            return "ev.charger.slash"
        }
    }
} 
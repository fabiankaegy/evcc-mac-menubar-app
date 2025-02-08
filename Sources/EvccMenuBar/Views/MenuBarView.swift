import SwiftUI

struct MenuBarView: View {
    @ObservedObject var evccState: EvccState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "bolt.fill")
                Text("Grid: \(formatPower(evccState.gridPower))")
            }
            
            HStack {
                Image(systemName: "sun.max.fill")
                Text("Solar: \(formatPower(evccState.pvPower))")
            }
            
            HStack {
                Image(systemName: evccState.batteryPower > 0 ? "battery.100.bolt" : "battery.100")
                Text("Battery: \(formatPower(evccState.batteryPower)) (\(Int(evccState.batterySoC))%)")
            }
            
            Divider()
            
            HStack {
                Image(systemName: "bolt.car.fill")
                if evccState.vehicleCharging {
                    Text("Charging: \(formatPower(evccState.vehiclePower))")
                } else {
                    Text("Not Charging")
                }
            }
            
            if evccState.vehicleSoC > 0 {
                Text("Vehicle SoC: \(Int(evccState.vehicleSoC))%")
            }
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
    }
    
    private func formatPower(_ power: Double) -> String {
        let absValue = abs(power)
        let prefix = power >= 0 ? "+" : "-"
        
        if absValue >= 1000 {
            // Convert to kW for values >= 1000W
            let kw = absValue / 1000
            return "\(prefix)\(String(format: "%.1f", kw)) kW"
        } else {
            // Keep as W for values < 1000W, rounded to whole numbers
            return "\(prefix)\(Int(absValue)) W"
        }
    }
} 
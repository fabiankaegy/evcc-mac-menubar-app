import SwiftUI

struct MenuBarView: View {
    @ObservedObject var evccState: EvccState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: evccState.gridPower > 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .foregroundColor(evccState.gridPower > 0 ? .red : .green)
                Text("\(evccState.gridPower > 0 ? "Consuming" : "Feeding"): \(formatPower(evccState.gridPower))")
            }
            
            HStack {
                Image(systemName: "sun.max.fill")
                    .foregroundColor(.yellow)
                Text("Solar: \(formatPower(evccState.pvPower))")
            }
            
            HStack {
                Image(systemName: evccState.batteryPower > 0 ? "battery.100.bolt" : "battery.100")
                    .foregroundColor(evccState.batteryPower > 0 ? .yellow : .green)
                Text("Battery: \(formatPower(evccState.batteryPower)) (\(Int(evccState.batterySoC))%)")
            }
            
            Divider()
            
            HStack {
                Image(systemName: "bolt.car.fill")
                    .foregroundColor(evccState.vehicleCharging ? .blue : .gray)
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
        .onAppear {
            evccState.setMenuExpanded(true)
        }
        .onDisappear {
            evccState.setMenuExpanded(false)
        }
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
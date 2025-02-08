import SwiftUI

enum ChargingMode: String, CaseIterable {
    case off = "Off"
    case now = "Fast"
    case minPv = "Min+PV"
    case pv = "PV"
    
    init(apiMode: String) {
        switch apiMode {
        case "off": self = .off
        case "now": self = .now
        case "min": self = .minPv
        case "pv": self = .pv
        default: self = .pv
        }
    }
    
    var icon: String {
        switch self {
        case .off: return "power"
        case .now: return "bolt.fill"
        case .minPv: return "sun.min"
        case .pv: return "sun.max"
        }
    }
}

struct CustomSegmentedControl: View {
    @Binding var selection: ChargingMode
    
    var body: some View {
        HStack(spacing: 1) {
            ForEach(ChargingMode.allCases, id: \.self) { mode in
                Button {
                    selection = mode
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: mode.icon)
                        Text(mode.rawValue)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity, minHeight: 24)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 6)
                .background(selection == mode ? Color.accentColor : Color.clear)
                .foregroundColor(selection == mode ? .white : .primary)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(NSColor.separatorColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct MenuBarView: View {
    @ObservedObject var evccState: EvccState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CustomSegmentedControl(selection: $evccState.currentMode)
                .padding(.bottom, 2)
            
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
                    Text("Charging: \(formatPower(evccState.vehiclePower)) (\(Int(evccState.vehicleSoC))%)")
                } else {
                    Text("Not Charging (\(Int(evccState.vehicleSoC))%)")
                }
            }
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .onAppear {
            evccState.setMenuExpanded(true)
        }
        .onDisappear {
            evccState.setMenuExpanded(false)
        }
        .onChange(of: evccState.currentMode) { newMode in
            evccState.setChargingMode(newMode)
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
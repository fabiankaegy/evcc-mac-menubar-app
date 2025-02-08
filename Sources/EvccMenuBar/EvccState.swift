import Foundation

class EvccState: ObservableObject {
    @Published var apiUrl: String = UserDefaults.standard.string(forKey: "evccApiUrl") ?? "http://192.168.1.58:7070/api"
    @Published var gridPower: Double = 0 // Positive = import, Negative = export
    @Published var pvPower: Double = 0
    @Published var batteryPower: Double = 0 // Positive = charging, Negative = discharging
    @Published var batterySoC: Double = 0
    @Published var vehicleCharging: Bool = false
    @Published var vehiclePower: Double = 0
    @Published var vehicleSoC: Double = 0
    @Published var currentMode: ChargingMode = .pv
    @Published var vehicleConnected: Bool = false
    @Published var vehicleRange: Double = 0
    
    private var timer: Timer?
    private let expandedPollingInterval: TimeInterval = 5.0
    private let collapsedPollingInterval: TimeInterval = 60.0
    private var isExpanded: Bool = false
    
    init() {
        startPolling(expanded: false)
    }
    
    func setMenuExpanded(_ expanded: Bool) {
        if isExpanded != expanded {
            isExpanded = expanded
            startPolling(expanded: expanded)
        }
    }
    
    private func startPolling(expanded: Bool) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: expanded ? expandedPollingInterval : collapsedPollingInterval, 
                                   repeats: true) { [weak self] _ in
            self?.fetchStatus()
        }
        // Fetch immediately when starting polling
        fetchStatus()
    }
    
    func fetchStatus() {
        guard let url = URL(string: "\(apiUrl)/state") else { 
            print("Invalid URL: \(apiUrl)/state")
            return 
        }
        
        print("Fetching from URL: \(url)")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let json = try JSONDecoder().decode(EvccStatus.self, from: data)
                DispatchQueue.main.async {
                    self?.updateState(with: json)
                }
            } catch {
                print("Error decoding JSON: \(error)")
                if let dataString = String(data: data, encoding: .utf8) {
                    print("Received data: \(dataString)")
                }
            }
        }.resume()
    }
    
    func updateApiUrl(_ newUrl: String) {
        apiUrl = newUrl
        UserDefaults.standard.set(newUrl, forKey: "evccApiUrl")
    }
    
    func updateState(with status: EvccStatus) {
        self.gridPower = status.result.grid.power
        self.pvPower = status.result.pv.first?.power ?? 0
        
        if let firstBattery = status.result.battery?.first {
            self.batteryPower = firstBattery.power
            self.batterySoC = firstBattery.soc
        } else {
            self.batteryPower = 0
            self.batterySoC = 0
        }
        
        if let firstVehicle = status.result.loadpoints.first {
            self.vehicleCharging = firstVehicle.charging
            self.vehicleConnected = firstVehicle.connected
            self.vehiclePower = firstVehicle.chargePower
            self.vehicleSoC = firstVehicle.vehicleSoc ?? 0
            self.vehicleRange = firstVehicle.vehicleRange ?? 0
            self.currentMode = ChargingMode(apiMode: firstVehicle.mode)
        }
    }
    
    func setChargingMode(_ mode: ChargingMode) {
        // Convert mode to evcc API mode string
        let modeString = switch mode {
        case .off: "off"
        case .now: "now"
        case .minPv: "minpv"
        case .pv: "pv"
        }
        
        guard let url = URL(string: "\(apiUrl)/loadpoints/1/mode/\(modeString)") else {
            print("Invalid URL for mode change: \(apiUrl)/loadpoints/1/mode/\(modeString)")
            return
        }
        
        print("Setting charging mode to '\(modeString)' at URL: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error setting mode: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Mode change response status: \(httpResponse.statusCode)")
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Mode change response: \(responseString)")
            }
            
            // Fetch updated status after mode change
            self?.fetchStatus()
        }.resume()
    }
} 

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
            self.vehiclePower = firstVehicle.chargePower
            self.vehicleSoC = firstVehicle.vehicleSoc ?? 0
        }
    }
} 

import Foundation

struct EvccStatus: Codable {
    let result: Result
    
    struct Result: Codable {
        let grid: Grid
        let pv: [PV]
        let battery: [Battery]?
        let loadpoints: [Loadpoint]
        
        struct Grid: Codable {
            let power: Double
        }
        
        struct PV: Codable {
            let power: Double
        }
        
        struct Battery: Codable {
            let power: Double
            let soc: Double
        }
        
        struct Loadpoint: Codable {
            let charging: Bool
            let chargePower: Double
            let vehicleSoc: Double?
        }
    }
} 
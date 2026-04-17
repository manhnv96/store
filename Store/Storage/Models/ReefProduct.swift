//
//  ReefProduct.swift
//  Store
//

import Foundation

enum ReefProductCategory: String, CaseIterable, Identifiable {
    case controller
    case dosingPump
    case lighting
    case sensor
    case supplement
    case wavemaker

    var id: String { rawValue }

    var title: String {
        switch self {
        case .controller: return "Controllers"
        case .dosingPump: return "Dosing Pumps"
        case .lighting: return "Lighting"
        case .sensor: return "Sensors"
        case .supplement: return "Supplements"
        case .wavemaker: return "Wavemakers"
        }
    }

    var iconName: String {
        switch self {
        case .controller: return "cpu"
        case .dosingPump: return "drop.circle"
        case .lighting: return "lightbulb.led.wide"
        case .sensor: return "sensor"
        case .supplement: return "flask"
        case .wavemaker: return "water.waves"
        }
    }
}

struct ReefProduct: Identifiable, Hashable {
    let id: String
    let category: ReefProductCategory
    let name: String
    let subtitle: String
    let description: String
    let features: [String]
    let price: Double
    let originalPrice: Double?
    let imageName: String
    let rating: Double
    let reviewCount: Int
    let inStock: Bool
}

extension ReefProduct {
    var formattedPrice: String {
        String(format: "$%.2f", price)
    }

    var formattedOriginalPrice: String? {
        guard let original = originalPrice else { return nil }
        return String(format: "$%.2f", original)
    }

    var discountPercent: Int? {
        guard let original = originalPrice, original > price else { return nil }
        return Int(((original - price) / original) * 100)
    }
}

// MARK: - Mock Data

extension ReefProduct {
    static let mocks: [ReefProduct] = [
        // Controllers
        ReefProduct(
            id: "ctrl-01",
            category: .controller,
            name: "ReefMaster Pro X1",
            subtitle: "All-in-one reef controller",
            description: "The ReefMaster Pro X1 is the ultimate reef aquarium controller. Monitor and control temperature, pH, salinity, ORP, and more from a single device. Features WiFi and Bluetooth connectivity, allowing remote access from anywhere. The 5-inch touchscreen display provides real-time data at a glance, while the powerful automation engine handles dosing schedules, lighting profiles, and emergency shutoffs.",
            features: [
                "5\" HD touchscreen display",
                "WiFi + Bluetooth connectivity",
                "Supports up to 8 sensor probes",
                "Automated dosing control",
                "Storm & moonlight simulation",
                "Power outage alerts",
                "iOS & Android app"
            ],
            price: 549.99,
            originalPrice: 649.99,
            imageName: "cpu",
            rating: 4.8,
            reviewCount: 234,
            inStock: true
        ),
        ReefProduct(
            id: "ctrl-02",
            category: .controller,
            name: "AquaLink Mini",
            subtitle: "Compact smart controller",
            description: "Perfect for nano and mid-size reef tanks. The AquaLink Mini packs essential monitoring and automation into a compact form factor. Track temperature, pH, and salinity with included probes. Set up alerts and basic dosing schedules through the companion app.",
            features: [
                "Compact design for small spaces",
                "3 included sensor probes",
                "WiFi connectivity",
                "Basic dosing timer",
                "Mobile app control"
            ],
            price: 199.99,
            originalPrice: nil,
            imageName: "cpu",
            rating: 4.5,
            reviewCount: 128,
            inStock: true
        ),

        // Dosing Pumps
        ReefProduct(
            id: "dose-01",
            category: .dosingPump,
            name: "PrecisionDose 4-Head",
            subtitle: "4-channel peristaltic dosing pump",
            description: "Maintain perfect water chemistry with the PrecisionDose 4-Head. Four independent peristaltic pump heads deliver precise amounts of calcium, alkalinity, magnesium, and trace elements on customizable schedules. The self-calibrating system ensures accuracy down to 0.01ml per dose.",
            features: [
                "4 independent pump channels",
                "0.01ml dosing precision",
                "Self-calibrating system",
                "Programmable schedules",
                "Low-reservoir alerts",
                "Quiet stepper motors",
                "WiFi integration"
            ],
            price: 329.99,
            originalPrice: 399.99,
            imageName: "drop.circle",
            rating: 4.7,
            reviewCount: 189,
            inStock: true
        ),
        ReefProduct(
            id: "dose-02",
            category: .dosingPump,
            name: "NanoDose Single",
            subtitle: "Single-channel micro doser",
            description: "An affordable single-channel dosing pump ideal for nano tanks or supplementing an existing setup. Simple dial programming with reliable delivery.",
            features: [
                "Single pump channel",
                "0.1ml precision",
                "Manual dial programming",
                "Compact footprint",
                "Silent operation"
            ],
            price: 59.99,
            originalPrice: nil,
            imageName: "drop.circle",
            rating: 4.3,
            reviewCount: 76,
            inStock: true
        ),

        // Lighting
        ReefProduct(
            id: "light-01",
            category: .lighting,
            name: "CoralSpectrum 300W",
            subtitle: "Full-spectrum reef LED",
            description: "The CoralSpectrum 300W delivers the perfect light spectrum for coral growth and coloration. Featuring UV, violet, royal blue, blue, cyan, green, and warm white LEDs, it covers the entire PAR spectrum corals need. Built-in wireless control lets you create sunrise/sunset schedules, cloud simulations, and lunar cycles.",
            features: [
                "300W total output",
                "7-channel spectrum control",
                "UV + violet for fluorescence",
                "Sunrise/sunset simulation",
                "Moonlight mode",
                "Wireless control & app",
                "Fanless passive cooling"
            ],
            price: 449.99,
            originalPrice: 529.99,
            imageName: "lightbulb.led.wide",
            rating: 4.9,
            reviewCount: 312,
            inStock: true
        ),

        // Sensors
        ReefProduct(
            id: "sensor-01",
            category: .sensor,
            name: "MultiProbe pH/KH/Ca",
            subtitle: "3-in-1 water parameter sensor",
            description: "Continuously monitor pH, KH, and Calcium levels with a single probe unit. Industrial-grade sensors provide lab-accurate readings every 60 seconds. Compatible with all major reef controllers.",
            features: [
                "pH, KH, Ca monitoring",
                "Lab-grade accuracy",
                "60-second reading interval",
                "Universal controller compatibility",
                "6-month probe life",
                "Easy calibration kit included"
            ],
            price: 189.99,
            originalPrice: nil,
            imageName: "sensor",
            rating: 4.6,
            reviewCount: 145,
            inStock: true
        ),
        ReefProduct(
            id: "sensor-02",
            category: .sensor,
            name: "TempGuard Wireless",
            subtitle: "Wireless temperature monitor",
            description: "A standalone wireless temperature sensor with built-in alerts. Place it in your sump or display tank and receive instant notifications if temperature drifts outside your set range. Battery lasts up to 12 months.",
            features: [
                "±0.1°C accuracy",
                "Wireless Bluetooth connection",
                "High/low temp alerts",
                "12-month battery life",
                "Waterproof IP68"
            ],
            price: 39.99,
            originalPrice: 49.99,
            imageName: "sensor",
            rating: 4.4,
            reviewCount: 203,
            inStock: true
        ),

        // Supplements
        ReefProduct(
            id: "supp-01",
            category: .supplement,
            name: "Reef Essentials Kit",
            subtitle: "Ca / Alk / Mg supplement bundle",
            description: "Everything you need to maintain stable reef water chemistry. This kit includes concentrated Calcium, Alkalinity, and Magnesium solutions designed for dosing pumps. Each 500ml bottle provides approximately 2 months of supplementation for a 200-liter tank.",
            features: [
                "3x 500ml concentrated solutions",
                "Calcium chloride formula",
                "Sodium bicarbonate alkalinity",
                "Magnesium sulfate/chloride blend",
                "Dosing pump compatible",
                "2-month supply per bottle"
            ],
            price: 44.99,
            originalPrice: nil,
            imageName: "flask",
            rating: 4.7,
            reviewCount: 421,
            inStock: true
        ),
        ReefProduct(
            id: "supp-02",
            category: .supplement,
            name: "Trace Elements Plus",
            subtitle: "Advanced trace element blend",
            description: "A premium blend of iodine, strontium, iron, manganese, and other essential trace elements that corals deplete from reef water. Formulated for weekly dosing to keep your reef vibrant and healthy.",
            features: [
                "13 essential trace elements",
                "Weekly dosing formula",
                "250ml bottle — 4 month supply",
                "Safe for all corals & invertebrates"
            ],
            price: 24.99,
            originalPrice: 29.99,
            imageName: "flask",
            rating: 4.5,
            reviewCount: 167,
            inStock: false
        ),

        // Wavemakers
        ReefProduct(
            id: "wave-01",
            category: .wavemaker,
            name: "TideFlow 6000",
            subtitle: "Controllable DC wavemaker",
            description: "Create natural ocean-like water movement in your reef tank. The TideFlow 6000 produces up to 6000 LPH of flow with ultra-quiet DC motor technology. Multiple wave patterns including pulse, gyre, tidal, and random modes keep corals healthy and detritus suspended.",
            features: [
                "6000 LPH max flow",
                "DC motor — ultra quiet",
                "7 wave patterns",
                "Wireless controller included",
                "Feed mode (10-min pause)",
                "Night mode (reduced flow)",
                "Magnetic mount up to 15mm glass"
            ],
            price: 129.99,
            originalPrice: 159.99,
            imageName: "water.waves",
            rating: 4.6,
            reviewCount: 278,
            inStock: true
        )
    ]
}

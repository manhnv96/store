//
//  WaterParameter.swift
//  Store
//

import Foundation

enum WaterParameterType: String, CaseIterable, Identifiable {
    case temperature
    case ph
    case kh
    case ca
    case mg
    case no3
    case po4

    var id: String { rawValue }

    var title: String {
        switch self {
        case .temperature: return "Temp"
        case .ph: return "pH"
        case .kh: return "KH"
        case .ca: return "Ca"
        case .mg: return "Mg"
        case .no3: return "NO3"
        case .po4: return "PO4"
        }
    }

    var unit: String {
        switch self {
        case .temperature: return "°C"
        case .ph: return ""
        case .kh: return "dKH"
        case .ca: return "ppm"
        case .mg: return "ppm"
        case .no3: return "ppm"
        case .po4: return "ppm"
        }
    }

    var iconSystemName: String {
        switch self {
        case .temperature: return "thermometer.medium"
        case .ph: return "drop.fill"
        case .kh: return "testtube.2"
        case .ca: return "atom"
        case .mg: return "sparkles"
        case .no3: return "leaf.fill"
        case .po4: return "circle.hexagongrid.fill"
        }
    }

    var chartColor: String {
        switch self {
        case .temperature: return "blue"
        case .ph: return "purple"
        case .kh: return "orange"
        case .ca: return "green"
        case .mg: return "pink"
        case .no3: return "red"
        case .po4: return "cyan"
        }
    }

    var idealRange: ClosedRange<Double> {
        switch self {
        case .temperature: return 24...26
        case .ph: return 8.0...8.4
        case .kh: return 7...11
        case .ca: return 380...450
        case .mg: return 1250...1400
        case .no3: return 1...10
        case .po4: return 0.02...0.1
        }
    }
}

struct WaterReading: Identifiable {
    let id = UUID()
    let type: WaterParameterType
    let value: Double
    let timestamp: Date
}

struct WaterParameterSummary: Identifiable {
    let id: WaterParameterType
    let type: WaterParameterType
    let currentValue: Double
    let readings: [WaterReading]

    var isInRange: Bool {
        type.idealRange.contains(currentValue)
    }

    var formattedValue: String {
        switch type {
        case .po4:
            return String(format: "%.2f", currentValue)
        case .ph:
            return String(format: "%.1f", currentValue)
        case .temperature:
            return String(format: "%.1f", currentValue)
        default:
            return String(format: "%.0f", currentValue)
        }
    }
}

#if DEBUG
extension WaterParameterSummary {
    static func mockReadings(for type: WaterParameterType, hours: Int = 48) -> [WaterReading] {
        let range = type.idealRange
        let mid = (range.lowerBound + range.upperBound) / 2
        let spread = (range.upperBound - range.lowerBound) * 0.6

        return (0..<hours).map { i in
            let hoursAgo = Double(hours - i)
            let noise = Double.random(in: -spread...spread)
            let value = mid + noise
            return WaterReading(
                type: type,
                value: value,
                timestamp: Date().addingTimeInterval(-hoursAgo * 3600)
            )
        }
    }

    static var mocks: [WaterParameterSummary] {
        WaterParameterType.allCases.map { type in
            let readings = mockReadings(for: type)
            return WaterParameterSummary(
                id: type,
                type: type,
                currentValue: readings.last?.value ?? 0,
                readings: readings
            )
        }
    }
}
#endif

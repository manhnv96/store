//
//  WaterParameter.swift
//  Store
//

import Foundation

enum WaterParameterType: String, CaseIterable, Identifiable, Hashable {
    case temperature
    case ph
    case kh
    case ca
    case mg
    case no3
    case po4
    case salinity
    case co2
    case oxygen

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
        case .salinity: return Language.WaterParameter.salinity
        case .co2: return "CO2"
        case .oxygen: return "O2"
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
        case .salinity: return "ppt"
        case .co2: return "ppm"
        case .oxygen: return "mg/L"
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
        case .salinity: return "water.waves"
        case .co2: return "carbon.dioxide.cloud.fill"
        case .oxygen: return "wind"
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
        case .salinity: return "teal"
        case .co2: return "indigo"
        case .oxygen: return "yellow"
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
        case .salinity: return 1.024...1.026
        case .co2: return 1...3
        case .oxygen: return 6...8
        }
    }
}

enum WaterParameterTrend {
    case up
    case down
    case stable

    var iconSystemName: String {
        switch self {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .stable: return "minus"
        }
    }
}

struct WaterReading: Identifiable, Hashable {
    let id: UUID
    let aquariumID: UUID
    let type: WaterParameterType
    let value: Double
    let timestamp: Date
    let source: WaterReadingSource
    let note: String?
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        aquariumID: UUID,
        type: WaterParameterType,
        value: Double,
        timestamp: Date,
        source: WaterReadingSource = .manual,
        note: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.aquariumID = aquariumID
        self.type = type
        self.value = value
        self.timestamp = timestamp
        self.source = source
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
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
        case .salinity:
            return String(format: "%.3f", currentValue)
        case .oxygen:
            return String(format: "%.1f", currentValue)
        default:
            return String(format: "%.0f", currentValue)
        }
    }

    /// Trend of the parameter computed from the average of the 3 most recent readings
    /// compared with the 3 preceding ones. Uses a 2% relative threshold to avoid noise.
    var trend: WaterParameterTrend {
        guard readings.count >= 6 else { return .stable }
        let sorted = readings.sorted { $0.timestamp < $1.timestamp }
        let recent = Array(sorted.suffix(3)).map(\.value)
        let prior = Array(sorted.dropLast(3).suffix(3)).map(\.value)
        let recentAvg = recent.reduce(0, +) / Double(recent.count)
        let priorAvg = prior.reduce(0, +) / Double(prior.count)
        let denom = max(abs(priorAvg), 0.0001)
        let relativeDelta = (recentAvg - priorAvg) / denom
        if abs(relativeDelta) < 0.02 { return .stable }
        return relativeDelta > 0 ? .up : .down
    }
}

#if DEBUG
extension WaterParameterSummary {
    static func mockReadings(for type: WaterParameterType, hours: Int = 48) -> [WaterReading] {
        let range = type.idealRange
        let mid = (range.lowerBound + range.upperBound) / 2
        let spread = (range.upperBound - range.lowerBound) * 0.6
        let aquariumID = UUID()

        return (0..<hours).map { i in
            let hoursAgo = Double(hours - i)
            let noise = Double.random(in: -spread...spread)
            let value = mid + noise
            let ts = Date().addingTimeInterval(-hoursAgo * 3600)
            return WaterReading(
                aquariumID: aquariumID,
                type: type,
                value: value,
                timestamp: ts,
                source: .device,
                createdAt: ts,
                updatedAt: ts
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

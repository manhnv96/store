//
//  DeviceKind.swift
//  LazyReef
//
//  Created by Mạnh Nguyễn Văn on 30/5/26.
//

import Foundation

enum DeviceKind: String, Codable, CaseIterable, Hashable {
    case skimmer
    case wavemaker
    case light
    case chiller
    case dosing
    case rollerFilter
    case pump
    case controller
    case sensor
    case other

    var displayName: String {
        switch self {
        case .skimmer: return Language.DeviceKind.skimmer
        case .wavemaker: return Language.DeviceKind.wavemaker
        case .light: return Language.DeviceKind.light
        case .chiller: return Language.DeviceKind.chiller
        case .dosing: return Language.DeviceKind.dosing
        case .rollerFilter: return Language.DeviceKind.rollerFilter
        case .pump: return Language.DeviceKind.pump
        case .controller: return Language.DeviceKind.controller
        case .sensor: return Language.DeviceKind.sensor
        case .other: return Language.DeviceKind.other
        }
    }

    var iconSystemName: String {
        switch self {
        case .skimmer: return "bubbles.and.sparkles"
        case .wavemaker: return "water.waves"
        case .light: return "lightbulb.led.wide"
        case .chiller: return "thermometer.snowflake"
        case .dosing: return "drop.circle"
        case .rollerFilter: return "arrow.triangle.2.circlepath"
        case .pump: return "fanblades"
        case .controller: return "cpu"
        case .sensor: return "sensor"
        case .other: return "shippingbox"
        }
    }

    /// Map a legacy / free-form category string to a structured DeviceKind.
    /// Handles QR `deviceType` values (controller, dosing_pump, lighting, wavemaker, pump, sensor)
    /// and stored rawValues, falling back to `.other` for unknown / empty input.
    static func from(rawCategory raw: String) -> DeviceKind {
        if let exact = DeviceKind(rawValue: raw) {
            return exact
        }
        switch raw.lowercased() {
        case "skimmer": return .skimmer
        case "wavemaker", "wave": return .wavemaker
        case "lighting", "light", "led": return .light
        case "chiller", "cooler": return .chiller
        case "dosing", "dosing_pump", "dosingpump", "doser": return .dosing
        case "roller", "rollerfilter", "roller_filter", "roll": return .rollerFilter
        case "pump", "returnpump", "return_pump": return .pump
        case "controller", "ctrl": return .controller
        case "sensor", "probe": return .sensor
        default: return .other
        }
    }
}

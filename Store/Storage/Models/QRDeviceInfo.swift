//
//  QRDeviceInfo.swift
//  Store
//

import Foundation

/// Represents the data encoded in a device QR code.
/// Expected JSON format:
/// {
///   "identifier": "REEF-CTRL-001",
///   "deviceType": "controller",
///   "name": "ReefMaster Pro X1",
///   "manufacturer": "ReefTech",
///   "model": "X1-2026",
///   "firmwareVersion": "2.1.0",
///   "datePublish": "2026-01-15",
///   "connectionType": "wifi"
/// }
struct QRDeviceInfo: Codable, Hashable {
    let identifier: String
    let deviceType: String
    let name: String
    let manufacturer: String
    let model: String
    let firmwareVersion: String
    let datePublish: String
    let connectionType: String

    var parsedConnectionType: ConnectionType {
        ConnectionType(rawValue: connectionType) ?? .wifi
    }

    var publishDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: datePublish)
    }

    var deviceTypeIcon: String {
        switch deviceType.lowercased() {
        case "controller": return "cpu"
        case "dosingpump", "dosing_pump": return "drop.circle"
        case "lighting", "light": return "lightbulb.led.wide"
        case "sensor": return "sensor"
        case "wavemaker": return "water.waves"
        case "pump": return "fanblades"
        default: return "shippingbox"
        }
    }

    func toConnectedDevice(folderID: UUID? = nil) -> ConnectedDevice {
        ConnectedDevice(
            id: UUID(),
            deviceName: name,
            inputName: identifier,
            deviceDescription: "\(manufacturer) \(model) — FW \(firmwareVersion)",
            category: deviceType,
            connectionType: parsedConnectionType,
            connectedDate: .now,
            lastUpdate: .now,
            parentFolderID: folderID
        )
    }
}

// MARK: - Mock

#if DEBUG
extension QRDeviceInfo {
    static let mock = QRDeviceInfo(
        identifier: "REEF-CTRL-001",
        deviceType: "controller",
        name: "ReefMaster Pro X1",
        manufacturer: "ReefTech",
        model: "X1-2026",
        firmwareVersion: "2.1.0",
        datePublish: "2026-01-15",
        connectionType: "wifi"
    )
}
#endif

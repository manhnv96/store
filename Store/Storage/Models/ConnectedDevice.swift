//
//  ConnectedDevice.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 04/4/26.
//

import Foundation

struct ConnectedDevice: Identifiable, Hashable {
    let id: UUID
    var deviceName: String
    var inputName: String
    var deviceDescription: String
    var category: String
    var connectionType: ConnectionType
    var connectedDate: Date
    var lastUpdate: Date
    var parentFolderID: UUID?
}

#if DEBUG
extension ConnectedDevice {
    static let mocks: [ConnectedDevice] = [
        ConnectedDevice(
            id: UUID(),
            deviceName: "Smart Speaker",
            inputName: "BLE-Speaker-01",
            deviceDescription: "Bluetooth speaker in living room",
            category: "Audio",
            connectionType: .bluetooth,
            connectedDate: Date(),
            lastUpdate: Date(),
            parentFolderID: nil
        ),
        ConnectedDevice(
            id: UUID(),
            deviceName: "Home Camera",
            inputName: "CAM-192.168.1.10",
            deviceDescription: "Front door camera",
            category: "Security",
            connectionType: .wifi,
            connectedDate: Date(),
            lastUpdate: Date(),
            parentFolderID: nil
        )
    ]
}
#endif

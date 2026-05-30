//
//  DeviceEntity.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 04/4/26.
//

import CoreData

@objc(DeviceEntity)
final class DeviceEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var deviceName: String?
    @NSManaged var inputName: String?
    @NSManaged var desc: String?
    @NSManaged var category: String?
    @NSManaged var connectionType: String?
    @NSManaged var connectedDate: Date?
    @NSManaged var lastUpdate: Date?
    @NSManaged var parentFolderID: UUID?
    @NSManaged var parentAquariumID: UUID?
}

extension DeviceEntity {
    func toDomain() -> ConnectedDevice? {
        guard
            let id,
            let deviceName,
            let inputName,
            let category,
            let connectionTypeRaw = connectionType,
            let connectionType = ConnectionType(rawValue: connectionTypeRaw),
            let connectedDate,
            let lastUpdate
        else { return nil }

        return ConnectedDevice(
            id: id,
            deviceName: deviceName,
            inputName: inputName,
            deviceDescription: desc ?? "",
            category: category,
            connectionType: connectionType,
            connectedDate: connectedDate,
            lastUpdate: lastUpdate,
            parentFolderID: parentFolderID,
            parentAquariumID: parentAquariumID
        )
    }

    func apply(_ device: ConnectedDevice) {
        id = device.id
        deviceName = device.deviceName
        inputName = device.inputName
        desc = device.deviceDescription
        category = device.category
        connectionType = device.connectionType.rawValue
        connectedDate = device.connectedDate
        lastUpdate = device.lastUpdate
        parentFolderID = device.parentFolderID
        parentAquariumID = device.parentAquariumID
    }
}

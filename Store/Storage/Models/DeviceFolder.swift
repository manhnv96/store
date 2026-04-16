//
//  DeviceFolder.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 04/4/26.
//

import Foundation

struct DeviceFolder: Identifiable, Hashable {
    let id: UUID
    var parentFolderID: UUID?
    var name: String
    var iconName: String
    var createdDate: Date
    var updatedDate: Date?
    var lastOpenDate: Date?
}

#if DEBUG
extension DeviceFolder {
    static let mocks: [DeviceFolder] = {
        let livingRoom = UUID()
        return [
            DeviceFolder(
                id: livingRoom,
                name: "Living Room",
                iconName: "folder",
                createdDate: Date(),
                updatedDate: Date(),
                lastOpenDate: Date()
            ),
            DeviceFolder(
                id: UUID(),
                name: "Office",
                iconName: "desktopcomputer",
                createdDate: Date(),
                updatedDate: Date(),
                lastOpenDate: nil
            ),
            DeviceFolder(
                id: UUID(),
                parentFolderID: livingRoom,
                name: "Lights",
                iconName: "lightbulb",
                createdDate: Date(),
                updatedDate: Date(),
                lastOpenDate: nil
            ),
            DeviceFolder(
                id: UUID(),
                parentFolderID: livingRoom,
                name: "Speakers",
                iconName: "hifispeaker",
                createdDate: Date(),
                updatedDate: Date(),
                lastOpenDate: nil
            )
        ]
    }()
}
#endif

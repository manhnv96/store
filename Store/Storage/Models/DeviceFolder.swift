//
//  DeviceFolder.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 04/4/26.
//

import Foundation

struct DeviceFolder: Identifiable, Hashable {
    let id: UUID
    var name: String
    var createdDate: Date
    var updatedDate: Date
    var lastOpenDate: Date?
}

#if DEBUG
extension DeviceFolder {
    static let mocks: [DeviceFolder] = [
        DeviceFolder(
            id: UUID(),
            name: "Living Room",
            createdDate: Date(),
            updatedDate: Date(),
            lastOpenDate: Date()
        ),
        DeviceFolder(
            id: UUID(),
            name: "Office",
            createdDate: Date(),
            updatedDate: Date(),
            lastOpenDate: nil
        )
    ]
}
#endif

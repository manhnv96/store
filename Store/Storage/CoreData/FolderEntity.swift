//
//  FolderEntity.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 04/4/26.
//

import CoreData

@objc(FolderEntity)
final class FolderEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var name: String?
    @NSManaged var createdDate: Date?
    @NSManaged var updatedDate: Date?
    @NSManaged var lastOpenDate: Date?
}

extension FolderEntity {
    func toDomain() -> DeviceFolder? {
        guard
            let id,
            let name,
            let createdDate,
            let updatedDate
        else { return nil }

        return DeviceFolder(
            id: id,
            name: name,
            createdDate: createdDate,
            updatedDate: updatedDate,
            lastOpenDate: lastOpenDate
        )
    }

    func apply(_ folder: DeviceFolder) {
        id = folder.id
        name = folder.name
        createdDate = folder.createdDate
        updatedDate = folder.updatedDate
        lastOpenDate = folder.lastOpenDate
    }
}

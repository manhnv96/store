//
//  AquariumEntity.swift
//  LazyReef
//
//  Created by Mạnh Nguyễn Văn on 30/5/26.
//

import CoreData

@objc(AquariumEntity)
final class AquariumEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var name: String?
    @NSManaged var iconName: String?
    @NSManaged var parentFolderID: UUID?
    @NSManaged var createdDate: Date?
    @NSManaged var updatedDate: Date?
    @NSManaged var lastOpenDate: Date?
}

extension AquariumEntity {
    func toDomain() -> Aquarium? {
        guard
            let id,
            let name,
            let createdDate
        else { return nil }

        return Aquarium(
            id: id,
            parentFolderID: parentFolderID,
            name: name,
            iconName: iconName ?? "drop.fill",
            createdDate: createdDate,
            updatedDate: updatedDate,
            lastOpenDate: lastOpenDate
        )
    }

    func apply(_ aquarium: Aquarium) {
        id = aquarium.id
        name = aquarium.name
        iconName = aquarium.iconName
        parentFolderID = aquarium.parentFolderID
        createdDate = aquarium.createdDate
        updatedDate = aquarium.updatedDate
        lastOpenDate = aquarium.lastOpenDate
    }
}

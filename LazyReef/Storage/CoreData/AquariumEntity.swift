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
    @NSManaged var sumpTypeRaw: String?
    @NSManaged var livestockTypeRaw: String?
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
            sumpType: sumpTypeRaw.flatMap(AquariumSumpType.init(rawValue:)),
            livestockType: livestockTypeRaw.flatMap(AquariumLivestockType.init(rawValue:)),
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
        sumpTypeRaw = aquarium.sumpType?.rawValue
        livestockTypeRaw = aquarium.livestockType?.rawValue
        createdDate = aquarium.createdDate
        updatedDate = aquarium.updatedDate
        lastOpenDate = aquarium.lastOpenDate
    }
}

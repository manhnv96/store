//
//  PersistenceController.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 04/4/26.
//

import CoreData

/// Manages the CoreData stack. Uses a programmatic model so no .xcdatamodeld file is required.
final class PersistenceController: @unchecked Sendable {

    static let shared = PersistenceController()

    // In-memory store used for SwiftUI Previews and unit tests.
    static let preview = PersistenceController(inMemory: true)

    let container: NSPersistentContainer

    // MARK: - Init

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(
            name: "Store",
            managedObjectModel: Self.makeModel()
        )
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("CoreData failed to load persistent store: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Programmatic Model

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        model.entities = [
            makeDeviceEntityDescription(),
            makeFolderEntityDescription(),
            makeAquariumEntityDescription(),
            makeWaterReadingEntityDescription()
        ]
        return model
    }

    private static func makeDeviceEntityDescription() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "DeviceEntity"
        entity.managedObjectClassName = "DeviceEntity"

        let specs: [(String, NSAttributeType)] = [
            ("id", .UUIDAttributeType),
            ("deviceName", .stringAttributeType),
            ("inputName", .stringAttributeType),
            ("desc", .stringAttributeType),
            ("category", .stringAttributeType),
            ("connectionType", .stringAttributeType),
            ("connectedDate", .dateAttributeType),
            ("lastUpdate", .dateAttributeType),
            ("parentFolderID", .UUIDAttributeType),
            ("parentAquariumID", .UUIDAttributeType)
        ]

        entity.properties = specs.map { name, type in
            let attr = NSAttributeDescription()
            attr.name = name
            attr.attributeType = type
            attr.isOptional = true
            return attr
        }
        return entity
    }

    private static func makeFolderEntityDescription() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "FolderEntity"
        entity.managedObjectClassName = "FolderEntity"

        let specs: [(String, NSAttributeType)] = [
            ("id", .UUIDAttributeType),
            ("name", .stringAttributeType),
            ("iconName", .stringAttributeType),
            ("createdDate", .dateAttributeType),
            ("updatedDate", .dateAttributeType),
            ("lastOpenDate", .dateAttributeType),
            ("parentFolderID", .UUIDAttributeType)
        ]

        entity.properties = specs.map { name, type in
            let attr = NSAttributeDescription()
            attr.name = name
            attr.attributeType = type
            attr.isOptional = true
            return attr
        }
        return entity
    }

    private static func makeAquariumEntityDescription() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "AquariumEntity"
        entity.managedObjectClassName = "AquariumEntity"

        let specs: [(String, NSAttributeType)] = [
            ("id", .UUIDAttributeType),
            ("name", .stringAttributeType),
            ("iconName", .stringAttributeType),
            ("parentFolderID", .UUIDAttributeType),
            ("createdDate", .dateAttributeType),
            ("updatedDate", .dateAttributeType),
            ("lastOpenDate", .dateAttributeType)
        ]

        entity.properties = specs.map { name, type in
            let attr = NSAttributeDescription()
            attr.name = name
            attr.attributeType = type
            attr.isOptional = true
            return attr
        }
        return entity
    }

    private static func makeWaterReadingEntityDescription() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "WaterReadingEntity"
        entity.managedObjectClassName = "WaterReadingEntity"

        // `value` is a non-optional Double (default 0). Other UUID/String/Date are optional.
        let optionalSpecs: [(String, NSAttributeType)] = [
            ("id", .UUIDAttributeType),
            ("aquariumID", .UUIDAttributeType),
            ("parameter", .stringAttributeType),
            ("timestamp", .dateAttributeType),
            ("sourceRaw", .stringAttributeType),
            ("note", .stringAttributeType),
            ("createdAt", .dateAttributeType),
            ("updatedAt", .dateAttributeType)
        ]

        var props: [NSAttributeDescription] = optionalSpecs.map { name, type in
            let attr = NSAttributeDescription()
            attr.name = name
            attr.attributeType = type
            attr.isOptional = true
            return attr
        }

        let valueAttr = NSAttributeDescription()
        valueAttr.name = "value"
        valueAttr.attributeType = .doubleAttributeType
        valueAttr.isOptional = false
        valueAttr.defaultValue = 0.0
        props.append(valueAttr)

        entity.properties = props
        return entity
    }
}

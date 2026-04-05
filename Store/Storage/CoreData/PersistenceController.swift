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
        model.entities = [makeDeviceEntityDescription(), makeFolderEntityDescription()]
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
}

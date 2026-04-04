//
//  CoreDataDeviceRepository.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 04/4/26.
//

import CoreData

final class CoreDataDeviceRepository: DeviceRepository {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    // MARK: - Devices

    func fetchAllDevices() async throws -> [ConnectedDevice] {
        try await context.perform { [context] in
            let request = NSFetchRequest<DeviceEntity>(entityName: "DeviceEntity")
            request.sortDescriptors = [NSSortDescriptor(key: "connectedDate", ascending: false)]
            return try context.fetch(request).compactMap { $0.toDomain() }
        }
    }

    func fetchDevices(inFolder folderID: UUID?) async throws -> [ConnectedDevice] {
        try await context.perform { [context] in
            let request = NSFetchRequest<DeviceEntity>(entityName: "DeviceEntity")
            if let folderID {
                request.predicate = NSPredicate(format: "parentFolderID == %@", folderID as CVarArg)
            } else {
                request.predicate = NSPredicate(format: "parentFolderID == nil")
            }
            request.sortDescriptors = [NSSortDescriptor(key: "connectedDate", ascending: false)]
            return try context.fetch(request).compactMap { $0.toDomain() }
        }
    }

    func save(_ device: ConnectedDevice) async throws {
        try await context.perform { [context] in
            let entity = DeviceEntity(context: context)
            entity.apply(device)
            try context.save()
        }
    }

    func update(_ device: ConnectedDevice) async throws {
        try await context.perform { [context] in
            let request = NSFetchRequest<DeviceEntity>(entityName: "DeviceEntity")
            request.predicate = NSPredicate(format: "id == %@", device.id as CVarArg)
            request.fetchLimit = 1
            guard let entity = try context.fetch(request).first else { return }
            entity.apply(device)
            try context.save()
        }
    }

    func delete(deviceID: UUID) async throws {
        try await context.perform { [context] in
            let request = NSFetchRequest<DeviceEntity>(entityName: "DeviceEntity")
            request.predicate = NSPredicate(format: "id == %@", deviceID as CVarArg)
            request.fetchLimit = 1
            guard let entity = try context.fetch(request).first else { return }
            context.delete(entity)
            try context.save()
        }
    }

    // MARK: - Folders

    func fetchAllFolders() async throws -> [DeviceFolder] {
        try await context.perform { [context] in
            let request = NSFetchRequest<FolderEntity>(entityName: "FolderEntity")
            request.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: true)]
            return try context.fetch(request).compactMap { $0.toDomain() }
        }
    }

    func save(_ folder: DeviceFolder) async throws {
        try await context.perform { [context] in
            let entity = FolderEntity(context: context)
            entity.apply(folder)
            try context.save()
        }
    }

    func update(_ folder: DeviceFolder) async throws {
        try await context.perform { [context] in
            let request = NSFetchRequest<FolderEntity>(entityName: "FolderEntity")
            request.predicate = NSPredicate(format: "id == %@", folder.id as CVarArg)
            request.fetchLimit = 1
            guard let entity = try context.fetch(request).first else { return }
            entity.apply(folder)
            try context.save()
        }
    }

    func delete(folderID: UUID) async throws {
        try await context.perform { [context] in
            let request = NSFetchRequest<FolderEntity>(entityName: "FolderEntity")
            request.predicate = NSPredicate(format: "id == %@", folderID as CVarArg)
            request.fetchLimit = 1
            guard let entity = try context.fetch(request).first else { return }
            context.delete(entity)
            try context.save()
        }
    }
}

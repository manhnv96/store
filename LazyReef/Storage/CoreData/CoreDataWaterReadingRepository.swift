//
//  CoreDataWaterReadingRepository.swift
//  LazyReef
//
//  Created by Mạnh Nguyễn Văn on 30/5/26.
//

import CoreData

final class CoreDataWaterReadingRepository: WaterReadingRepository, @unchecked Sendable {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    func fetchReadings(aquariumID: UUID,
                       parameter: WaterParameterType?,
                       limit: Int) async throws -> [WaterReading] {
        try await context.perform { [context] in
            let request = NSFetchRequest<WaterReadingEntity>(entityName: "WaterReadingEntity")
            var predicates: [NSPredicate] = [
                NSPredicate(format: "aquariumID == %@", aquariumID as CVarArg)
            ]
            if let parameter {
                predicates.append(NSPredicate(format: "parameter == %@", parameter.rawValue))
            }
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            if limit > 0 {
                request.fetchLimit = limit
            }
            return try context.fetch(request).compactMap { $0.toDomain() }
        }
    }

    func save(_ reading: WaterReading) async throws {
        try await context.perform { [context] in
            let entity = WaterReadingEntity(context: context)
            entity.apply(reading)
            try context.save()
        }
    }

    func update(_ reading: WaterReading) async throws {
        try await context.perform { [context] in
            let request = NSFetchRequest<WaterReadingEntity>(entityName: "WaterReadingEntity")
            request.predicate = NSPredicate(format: "id == %@", reading.id as CVarArg)
            request.fetchLimit = 1
            guard let entity = try context.fetch(request).first else { return }
            entity.apply(reading)
            try context.save()
        }
    }

    func delete(readingID: UUID) async throws {
        try await context.perform { [context] in
            let request = NSFetchRequest<WaterReadingEntity>(entityName: "WaterReadingEntity")
            request.predicate = NSPredicate(format: "id == %@", readingID as CVarArg)
            request.fetchLimit = 1
            guard let entity = try context.fetch(request).first else { return }
            context.delete(entity)
            try context.save()
        }
    }
}

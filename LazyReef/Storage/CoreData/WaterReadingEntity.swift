//
//  WaterReadingEntity.swift
//  LazyReef
//
//  Created by Mạnh Nguyễn Văn on 30/5/26.
//

import CoreData

@objc(WaterReadingEntity)
final class WaterReadingEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var aquariumID: UUID?
    @NSManaged var parameter: String?
    @NSManaged var value: Double
    @NSManaged var timestamp: Date?
    @NSManaged var sourceRaw: String?
    @NSManaged var note: String?
    @NSManaged var createdAt: Date?
    @NSManaged var updatedAt: Date?
}

extension WaterReadingEntity {
    func toDomain() -> WaterReading? {
        guard
            let id,
            let aquariumID,
            let parameterRaw = parameter,
            let type = WaterParameterType(rawValue: parameterRaw),
            let timestamp,
            let sourceRaw,
            let source = WaterReadingSource(rawValue: sourceRaw),
            let createdAt,
            let updatedAt
        else { return nil }

        return WaterReading(
            id: id,
            aquariumID: aquariumID,
            type: type,
            value: value,
            timestamp: timestamp,
            source: source,
            note: note,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    func apply(_ reading: WaterReading) {
        id = reading.id
        aquariumID = reading.aquariumID
        parameter = reading.type.rawValue
        value = reading.value
        timestamp = reading.timestamp
        sourceRaw = reading.source.rawValue
        note = reading.note
        createdAt = reading.createdAt
        updatedAt = reading.updatedAt
    }
}

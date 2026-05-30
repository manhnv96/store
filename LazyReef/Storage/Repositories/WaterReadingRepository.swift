//
//  WaterReadingRepository.swift
//  LazyReef
//
//  Created by Mạnh Nguyễn Văn on 30/5/26.
//

import Foundation

protocol WaterReadingRepository: Sendable {
    /// Fetch readings for an aquarium, optionally filtered by parameter, ordered by `timestamp` DESC.
    /// Pass `limit = 0` to fetch all.
    func fetchReadings(aquariumID: UUID,
                       parameter: WaterParameterType?,
                       limit: Int) async throws -> [WaterReading]

    func save(_ reading: WaterReading) async throws
    func update(_ reading: WaterReading) async throws
    func delete(readingID: UUID) async throws
}

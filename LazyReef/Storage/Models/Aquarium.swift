//
//  Aquarium.swift
//  LazyReef
//
//  Created by Mạnh Nguyễn Văn on 30/5/26.
//

import Foundation

enum AquariumSumpType: String, CaseIterable, Codable, Hashable, Identifiable {
    case builtInFilter
    case overflowSump
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .builtInFilter: return Language.AquariumSetup.sumpBuiltIn
        case .overflowSump: return Language.AquariumSetup.sumpOverflow
        case .other: return Language.AquariumSetup.sumpOther
        }
    }

    var iconSystemName: String {
        switch self {
        case .builtInFilter: return "rectangle.inset.filled"
        case .overflowSump: return "arrow.down.to.line.compact"
        case .other: return "questionmark.square"
        }
    }
}

enum AquariumLivestockType: String, CaseIterable, Codable, Hashable, Identifiable {
    case onlyFish
    case softCoral
    case lps
    case sps
    case mix

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .onlyFish: return Language.AquariumSetup.livestockOnlyFish
        case .softCoral: return Language.AquariumSetup.livestockSoftCoral
        case .lps: return Language.AquariumSetup.livestockLPS
        case .sps: return Language.AquariumSetup.livestockSPS
        case .mix: return Language.AquariumSetup.livestockMix
        }
    }

    var iconSystemName: String {
        switch self {
        case .onlyFish: return "fish.fill"
        case .softCoral: return "leaf.fill"
        case .lps: return "circle.hexagongrid.fill"
        case .sps: return "rays"
        case .mix: return "sparkles"
        }
    }
}

struct Aquarium: Identifiable, Hashable {
    let id: UUID
    var parentFolderID: UUID?
    var name: String
    var iconName: String
    var sumpType: AquariumSumpType?
    var livestockType: AquariumLivestockType?
    var createdDate: Date
    var updatedDate: Date?
    var lastOpenDate: Date?
}

#if DEBUG
extension Aquarium {
    static let mocks: [Aquarium] = [
        Aquarium(
            id: UUID(),
            parentFolderID: nil,
            name: "Bể chính",
            iconName: "drop.fill",
            sumpType: .overflowSump,
            livestockType: .mix,
            createdDate: Date(),
            updatedDate: Date(),
            lastOpenDate: Date()
        ),
        Aquarium(
            id: UUID(),
            parentFolderID: nil,
            name: "Bể phụ",
            iconName: "drop",
            sumpType: nil,
            livestockType: nil,
            createdDate: Date(),
            updatedDate: Date(),
            lastOpenDate: nil
        )
    ]
}
#endif

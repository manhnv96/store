//
//  Aquarium.swift
//  LazyReef
//
//  Created by Mạnh Nguyễn Văn on 30/5/26.
//

import Foundation

struct Aquarium: Identifiable, Hashable {
    let id: UUID
    var parentFolderID: UUID?
    var name: String
    var iconName: String
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
            createdDate: Date(),
            updatedDate: Date(),
            lastOpenDate: Date()
        ),
        Aquarium(
            id: UUID(),
            parentFolderID: nil,
            name: "Bể phụ",
            iconName: "drop",
            createdDate: Date(),
            updatedDate: Date(),
            lastOpenDate: nil
        )
    ]
}
#endif

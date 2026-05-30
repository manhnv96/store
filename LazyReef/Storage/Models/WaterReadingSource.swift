//
//  WaterReadingSource.swift
//  LazyReef
//
//  Created by Mạnh Nguyễn Văn on 30/5/26.
//

import Foundation

enum WaterReadingSource: String, Codable, Hashable, CaseIterable {
    case manual
    case voice
    case device   // reserved for IoT ingestion (v2)
    case server   // reserved for external API import (v2)

    var iconSystemName: String {
        switch self {
        case .manual: return "pencil"
        case .voice: return "mic.fill"
        case .device: return "antenna.radiowaves.left.and.right"
        case .server: return "cloud.fill"
        }
    }

    var displayName: String {
        switch self {
        case .manual: return Language.LogSource.manual
        case .voice: return Language.LogSource.voice
        case .device: return Language.LogSource.device
        case .server: return Language.LogSource.server
        }
    }
}

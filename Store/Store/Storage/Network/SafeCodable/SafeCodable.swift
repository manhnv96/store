//
//  SafeCodable.swift
//  LunarCalendar
//
//  Created by Mạnh Nguyễn Văn on 7/9/24.
//  Copyright © 2024 Manh Nguyen Van. All rights reserved.
//

import Foundation

typealias SafeCodable = SafeDecodable & SafeEncodable

//MARK: SafeDecodable
protocol SafeDecodable: Decodable {
    init()
}

extension SafeDecodable {
    
    init(from decoder: any Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodableKey.self)
        for child in Mirror(reflecting: self).children {
            guard let decodableKey = child.value as? DecodableKey,
                  var label = child.label else {
                continue
            }
            
            if label.starts(with: "_") {
                label.removeFirst()
            }
            
            try decodableKey.decode(
                from: container,
                codingKey: CodableKey(stringValue: label)
            )
        }
    }
}

protocol DecodableKey {
    func decode(
        from container: KeyedDecodingContainer<CodableKey>,
        codingKey: CodableKey
    ) throws
}

//MARK: SafeEncodable

protocol EncodableKey {
    func encode(
        from container: inout KeyedEncodingContainer<CodableKey>,
        codingKey: CodableKey
    ) throws
}

protocol SafeEncodable: Encodable {}

extension SafeEncodable {
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodableKey.self)
        for child in Mirror(reflecting: self).children {
            if let encodableKey = child.value as? EncodableKey,
                  var label = child.label {
                if label.starts(with: "_") {
                    label.removeFirst()
                }
                
                try encodableKey.encode(
                    from: &container,
                    codingKey: CodableKey(stringValue: label)
                )
            } else if let label = child.label,
                      let value = child.value as? Encodable {
                try container.encode(value, forKey: CodableKey(stringValue: label))
            }
        }
    }
}

//
//  CodableKey.swift
//  LunarCalendar
//
//  Created by Mạnh Nguyễn Văn on 7/9/24.
//  Copyright © 2024 Manh Nguyen Van. All rights reserved.
//

import Foundation

@propertyWrapper
final class CodableProperty<Value> {
    let customKey: String?
    let alternativeKey: [String]?
    let codingPaths: [String]?
    let dateFormat: String?
    var wrappedValue: Value?
    var defaultValue: Value?
        
    init(
        customKey: String? = nil,
        alternativeKey: [String]? = nil,
        childPaths: [String]? = nil,
        dateFormat: String? = nil,
        wrappedValue: Value? = nil,
        defaultValue: Value? = nil
    ) {
        self.customKey = customKey
        self.alternativeKey = alternativeKey
        self.codingPaths = childPaths
        self.dateFormat = dateFormat
        self.wrappedValue = wrappedValue
        self.defaultValue = defaultValue
    }
}

extension CodableProperty {
    var dateFormatter: DateFormatter? {
        guard let dateFormat else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter
    }
}

extension CodableProperty: DecodableKey where Value: Decodable {
    
    func decode(
        from container: KeyedDecodingContainer<CodableKey>,
        codingKey: CodableKey
    ) throws {
        let _codingKey: CodableKey
        if let customKey, !customKey.isEmpty {
            _codingKey = CodableKey(stringValue: customKey)
        } else {
            _codingKey = codingKey
        }
        wrappedValue = decode(from: container, codingKey: _codingKey)
        if wrappedValue == nil {
            // Support decode from snake case into camel case
            // exp: leftMidARight can decode with key left_mid_a_right
            let snakeCase = codingKey.stringValue.camelCaseToSnakeCase()
            wrappedValue = decode(
                from: container,
                codingKey: CodableKey(stringValue: snakeCase)
            )
        }
        
        guard wrappedValue == nil else { return }
        
        let alternativeCodingKeys = alternativeKey?.map {
            CodableKey(stringValue: $0)
        }
        if let alternativeCodingKeys {
            for key in alternativeCodingKeys {
                if let value = decode(from: container, codingKey: key) {
                    wrappedValue = value
                    return
                }
            }
        }
        
        if let codingPaths, !codingPaths.isEmpty {
            var codingKeys = codingPaths.map { CodableKey(stringValue: $0) }
            var childContainer = container
            repeat {
                let codingKey = codingKeys.removeFirst()
                if codingKeys.isEmpty {
                    wrappedValue = try? childContainer.decodeIfPresent(Value.self, forKey: codingKey)
                } else {
                    childContainer = try childContainer.nestedContainer(keyedBy: CodableKey.self, forKey: codingKey)
                }
            } while !codingKeys.isEmpty
        }
    }
    
    private func decode(
        from container: KeyedDecodingContainer<CodableKey>,
        codingKey: CodableKey
    ) -> Value? {
        do {
            if Value.self == Date.self {
                return try decodeDate(from: container, codingKey: codingKey)
            } else {
                return try decodeValue(from: container, codingKey: codingKey)
            }
        } catch {
            debugPrint("Decode \(String(describing: Value.self)): \(error.localizedDescription)")
            return defaultValue
        }
    }
    
    private func decodeDate(
        from container: KeyedDecodingContainer<CodableKey>,
        codingKey: CodableKey
    ) throws -> Value? {
        guard let string = try container.decodeIfPresent(
            String.self,
            forKey: codingKey
        ) else {
            return defaultValue
        }

        return dateFormatter?.date(from: string) as? Value
    }
    
    private func decodeValue(
        from container: KeyedDecodingContainer<CodableKey>,
        codingKey: CodableKey
    ) throws -> Value? {
        try container.decodeIfPresent(
            Value.self,
            forKey: codingKey
        )
    }
}

extension CodableProperty: EncodableKey where Value: Encodable {
    func encode(
        from container: inout KeyedEncodingContainer<CodableKey>,
        codingKey: CodableKey
    ) throws {
        let _codingKey: CodableKey
        if let customKey, !customKey.isEmpty {
            _codingKey = CodableKey(stringValue: customKey)
        } else {
            _codingKey = codingKey
        }
        
        if let date = wrappedValue as? Date {
            if let dateFormatter {
                try container.encode(
                    dateFormatter.string(from: date),
                    forKey: _codingKey
                )
            } else {
                try container.encode(
                    date.timeIntervalSince1970,
                    forKey: _codingKey
                )
            }
        } else {
            try container.encode(wrappedValue, forKey: _codingKey)
        }
    }
}

fileprivate extension String {
    func camelCaseToSnakeCase() -> String {
        let acronymPattern = "([A-Z]+)([A-Z][a-z]|[0-9])"
        let fullWordsPattern = "([a-z])([A-Z]|[0-9])"
        let digitsFirstPattern = "([0-9])([A-Z])"
        return processCamelCaseRegex(pattern: acronymPattern)?
            .processCamelCaseRegex(pattern: fullWordsPattern)?
            .processCamelCaseRegex(pattern:digitsFirstPattern)?
            .lowercased() ?? self.lowercased()
    }
    
    func processCamelCaseRegex(pattern: String) -> String? {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: count)
        return regex?.stringByReplacingMatches(
            in: self,
            options: [],
            range: range,
            withTemplate: "$1_$2"
        )
    }
}

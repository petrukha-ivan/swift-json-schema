//
//  JSONSchema+ObjectProperties.swift
//  JSONSchema
//
//  Created by Ivan Petrukha on 05.10.2025.
//

import Foundation
import Collections

private struct AnyCodingKey: CodingKey, Hashable {
    
    let stringValue: String
    let intValue: Int?
    
    init(_ string: String) {
        self.stringValue = string
        self.intValue = nil
    }

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}

public extension JSONSchema.ObjectSchema {
    struct Properties: Sendable, Codable {
        
        public static let orderInfoKey = CodingUserInfoKey(rawValue: "JSONSchema.ObjectSchema.Properties.orderInfoKey")!
        
        public let ordered: OrderedDictionary<String, JSONSchema>
        
        public init(ordered: OrderedDictionary<String, JSONSchema>) {
            self.ordered = ordered
        }
        
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: AnyCodingKey.self)
            var ordered = OrderedDictionary<String, JSONSchema>()
            if let order = decoder.userInfo[Self.orderInfoKey] as? [String] {
                for key in order {
                    ordered[key] = try container.decode(JSONSchema.self, forKey: AnyCodingKey(key))
                }
            } else {
                for key in container.allKeys {
                    ordered[key.stringValue] = try container.decode(JSONSchema.self, forKey: key)
                }
            }
            self.ordered = ordered
        }
        
        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: AnyCodingKey.self)
            for (i, (key, value)) in ordered.enumerated() {
                try container.encode(value, forKey: AnyCodingKey("__\(i)__\(key)"))
            }
        }
    }
}

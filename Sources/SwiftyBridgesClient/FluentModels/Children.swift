import Foundation

public typealias Siblings = Children

/// A property of this type is generated if the corresponding property on the server uses Fluent's `@Children`. It references Fluent models on the server.
///
/// - Important: If this property contains am empty array this means that either the referenced objects have not been fetched on the server or that the model on the server references no objects.
@propertyWrapper
public struct Children<To: FluentModelStruct> {
    public var wrappedValue: [To]
    
    public init(wrappedValue: [To]) {
        self.wrappedValue = wrappedValue
    }
}

extension Children: Codable {
    public init(from decoder: Decoder) throws {
        do {
            wrappedValue = try .init(from: decoder)
        } catch let originalError {
            let container = try decoder.singleValueContainer()
            guard container.decodeNil() else {
                throw originalError
            }
            wrappedValue = []
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

extension Children: DecodableFromMissingKey {
    public init<Key>(fromMissingKey missingKey: Key, in container: KeyedDecodingContainer<Key>) where Key : CodingKey {
        wrappedValue = []
    }
}

extension Children: Equatable where To.IDValue: Equatable {
    public static func == (lhs: Children<To>, rhs: Children<To>) -> Bool {
        lhs.wrappedValue.map(\.id) == rhs.wrappedValue.map(\.id)
    }
}

extension Children: Hashable where To.IDValue: Hashable {
    public func hash(into hasher: inout Hasher) {
        wrappedValue.map(\.id).hash(into: &hasher)
    }
}

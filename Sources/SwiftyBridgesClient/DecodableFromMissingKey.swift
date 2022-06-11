import Foundation

public protocol DecodableFromMissingKey: Decodable {
    init<Key: CodingKey>(fromMissingKey missingKey: Key, in container: KeyedDecodingContainer<Key>)
}

extension KeyedDecodingContainer {
    // This is needed because Fluent sometimes does not send the key if the `Children` property has not been loaded from the database
    public func decode<T: DecodableFromMissingKey>(_ type: T.Type, forKey key: Self.Key) throws -> T {
        return try decodeIfPresent(T.self, forKey: key) ?? T(fromMissingKey: key, in: self)
    }
}

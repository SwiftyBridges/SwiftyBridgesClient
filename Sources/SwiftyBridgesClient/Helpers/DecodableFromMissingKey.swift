import Foundation

/// If a type of a property conforms to this protocol, it can be decoded even if the key of the property is missing in the data.
///
/// The reason is that Fluent sometimes does not send the key if the `Children` or `OptionalChild` property has not been loaded from the database.
/// 
/// For example, if `Info` conforms to `_DecodableFromMissingKey`, `Person` can be decoded from `json`:
///
/// ```swift
/// struct Person: Codable {
///     var name: String
///     var info: Info
/// }
///
/// let json = """
/// {
///     name: "John"
/// }
/// """
/// ```
///
/// - Important: Although this type is public for technical reasons, it is not considered part of the public interface of this package. Therefore, its behaviour might change or it may be removed from the package at any point.
/// 
public protocol _DecodableFromMissingKey: Decodable {
    /// This constuctor is called if a property of this type shall be decoded and its key is missing. The property is then initialized with the result of this initializer.
    /// - Parameters:
    ///   - missingKey: The key from which the property should have been decoded
    ///   - container: The container that contains the values used to decode the property's parent. It is missing the key.
    init<Key: CodingKey>(fromMissingKey missingKey: Key, in container: KeyedDecodingContainer<Key>) throws
}

extension KeyedDecodingContainer {
    /// This overload is called by the compiler-synthesized `Decodable` code if a type conforming to `_DecodableFromMissingKey` shall be decoded
    public func decode<T: _DecodableFromMissingKey>(_ type: T.Type, forKey key: Self.Key) throws -> T {
        return try decodeIfPresent(T.self, forKey: key) ?? T(fromMissingKey: key, in: self)
    }
}

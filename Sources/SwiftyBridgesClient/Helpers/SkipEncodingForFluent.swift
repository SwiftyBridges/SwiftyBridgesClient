import Foundation

/// If a type of a property conforms to this protocol, it is entirely skipped from being encoded if `Environment.encodingForFluent` is set to `true`
///
/// The reason for this is that Fluent does not decode the value of `Children` or `OptionalChild` properties.
///
/// For example, if `Info` conforms to `_SkipEncodingForFluent`, encoding `person` will not encode `info`:
///
/// ```swift
/// struct Person: Codable {
///     var name: String
///     var info: Info
/// }
///
/// let person = Person(name: "John", info: ...)
///
/// try Environment.$encodingForFluent.withValue(true) {
///     let jsonData = try JSONEncoder().encode(person)
///
///     // `jsonData` will look something like this:
///     // {
///     //     name: "John"
///     // }
/// }
/// ```
///
/// - Important: Although this type is public for technical reasons, it is not considered part of the public interface of this package. Therefore, its behaviour might change or it may be removed from the package at any point.
///
public protocol _SkipEncodingForFluent: Encodable {}

extension KeyedEncodingContainer {
    /// This overload is called by the compiler-synthesized `Encodable` code if a type conforming to `_SkipEncodingForFluent` shall be encoded
    public mutating func encode<T: _SkipEncodingForFluent>(_ value: T, forKey key: KeyedEncodingContainer<K>.Key) throws {
        if Environment.encodingForFluent {
            // If we are encoding data to be sent to Fluent, we don't need to encode anything because Fluent does not decode it
        } else {
            let encoder = self.superEncoder(forKey: key)
            try value.encode(to: encoder)
        }
    }
}

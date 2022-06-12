import Foundation

/// A property of this type is generated if the corresponding property on the server uses Fluent's `@OptionalChild`. It references a Fluent model on the server.
///
/// The ID of the referenced model can be read or set using the property directly. If the property values of the referenced instance have been sent by the server, it can be accessed using the property name preceded by `$`:
///
///     struct Child: FluentModelStruct {
///         var id: UUID?
///         var name: String
///     }
///
///     struct Parent: FluentModelStruct {
///         var id: UUID?
///
///         @OptionalChild<Child>
///         var child: Child.IDValue?
///     }
///
///     let parent: Parent = ...
///
///     let child: Child? = parent.$child
///
@propertyWrapper
public struct OptionalChild<To: FluentModelStruct> {
    /// The ID of the referenced model
    public var wrappedValue: To.IDValue? {
        didSet {
            if projectedValue?.id != wrappedValue {
                projectedValue = nil
            }
        }
    }
    
    /// Contains the full model if present. This is the case if the server sent the full model instead of only its ID.
    ///
    /// We store it indirectly because a generated struct may contain references to itself inside an `OptionalChild`. This would result in an error without `@Indirect`.
    @Indirect
    public private(set) var projectedValue: To?
    
    public init(wrappedValue: To.IDValue?) {
        self.wrappedValue = wrappedValue
    }
}

extension OptionalChild: Codable, _SkipEncodingForFluent {
    private enum CodingKeys: String, CodingKey {
        case id
    }
    
    public init(from decoder: Decoder) throws {
        if
            let value = try? To?(from: decoder),
            let id = value.id
        {
            // The whole parent was set. Save it in `projectedValue`.
            self.projectedValue = value
            self.wrappedValue = id
            return
        }
        
        // Only the ID was sent
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.wrappedValue = try container.decode(To.IDValue?.self, forKey: .id)
    }
    
    public func encode(to encoder: Encoder) throws {
        if let object = projectedValue {
            try object.encode(to: encoder)
        } else {
            try ["id": wrappedValue].encode(to: encoder)
        }
    }
}

extension OptionalChild: _DecodableFromMissingKey {
    public init<Key>(fromMissingKey missingKey: Key, in container: KeyedDecodingContainer<Key>) where Key : CodingKey {
        wrappedValue = nil
    }
}

extension OptionalChild: Equatable where To.IDValue: Equatable {
    public static func == (lhs: OptionalChild<To>, rhs: OptionalChild<To>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension OptionalChild: Hashable where To.IDValue: Hashable {
    public func hash(into hasher: inout Hasher) {
        wrappedValue.hash(into: &hasher)
    }
}

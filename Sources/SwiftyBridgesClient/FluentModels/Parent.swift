import Foundation

/// A property of this type is generated if the corresponding property on the server uses Fluent's `@Parent`. It references a Fluent model on the server.
///
/// The ID of the referenced model can be read or set using the property directly. If the property values of the referenced instance have been sent by the server, it can be accessed using the property name preceded by `$`:
///
///     struct Parent: FluentModelStruct {
///         var id: UUID?
///         var name: String
///     }
///
///     struct Child: FluentModelStruct {
///         var id: UUID?
///
///         @Parent<Parent>
///         var parent: Parent.IDValue
///     }
///
///     let child: Child = ...
///
///     let parent: Parent? = child.$parent
///
@propertyWrapper
public struct Parent<To: FluentModelStruct> {
    /// The ID of the referenced model
    public var wrappedValue: To.IDValue {
        didSet {
            if projectedValue?.id != wrappedValue {
                projectedValue = nil
            }
        }
    }
    
    /// Contains the full model if present. This is the case if the server sent the full model instead of only its ID.
    ///
    /// We store it indirectly because a generated struct may contain references to itself inside an `Parent`. This would result in an error without `@Indirect`.
    @Indirect
    public private(set) var projectedValue: To?
    
    public init(wrappedValue: To.IDValue) {
        self.wrappedValue = wrappedValue
    }
}

extension Parent: Codable {
    private enum CodingKeys: String, CodingKey {
        case id
    }
    
    public init(from decoder: Decoder) throws {
        if
            let value = try? To(from: decoder),
            let id = value.id
        {
            // The whole parent was set. Save it in `projectedValue`.
            self.projectedValue = value
            self.wrappedValue = id
            return
        }
        
        // Only the ID was sent
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.wrappedValue = try container.decode(To.IDValue.self, forKey: .id)
    }
    
    public func encode(to encoder: Encoder) throws {
        if
            let object = projectedValue,
            !Environment.encodingForFluent // If we are encoding data to be sent to Fluent, we don't need to encode the full object because Fluent does not decode it
        {
            try object.encode(to: encoder)
        } else {
            try ["id": wrappedValue].encode(to: encoder)
        }
    }
}

extension Parent: Equatable where To.IDValue: Equatable {
    public static func == (lhs: Parent<To>, rhs: Parent<To>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension Parent: Hashable where To.IDValue: Hashable {
    public func hash(into hasher: inout Hasher) {
        wrappedValue.hash(into: &hasher)
    }
}

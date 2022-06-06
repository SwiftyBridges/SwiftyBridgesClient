import Foundation

/// A property of this type is generated if the corresponding property on the server uses Fluent's `@Parent` or `@OptionalParent`. It references a Fluent model on the server.
///
/// The ID of the referenced model can be read or set using `id`. If the property values of the referenced instance have been sent by the server or if an instance of `Parent` has been provided to the initializer, there are two ways to access them:
///
///     struct Parent: FluentModelStruct {
///         var id: UUID?
///         var name: String
///     }
///
///     struct Child: FluentModelStruct {
///         var id: UUID?
///         var parent: ParentReference<Parent>
///     }
///
///     let child: Child = ...
///
/// In this case, the name of the parent can either be accessed directly on the reference:
///
///     let name: String? = child.parent.name
///
/// Alternatively, the parent can be accessed using `value`:
///
///     let parent: Parent? = child.parent.value
@dynamicMemberLookup
public struct ParentReference<Parent: FluentModelStruct> {
    /// The ID of the referenced model
    var id: Parent.IDValue {
        didSet {
            if value.id != id {
                boxedValue = nil
            }
        }
    }
    
    /// We store a boxed value instead of the value directly because a generated struct may contain references to itself inside a `ParentReference`. This would result in an error without `Boxed`. See `value`.
    private var boxedValue: Boxed<Parent>?
    
    /// Creates a reference containing only an ID
    public init(id: Parent.IDValue) {
        self.id = id
    }
    
    /// Creates a reference containing the full parent model. Returns `nil` if the ID of the parent is `nil`.
    public init?(_ parent: Parent) {
        guard let id = parent.id else { return nil }
        self.id = id
        self.boxedValue = .init(parent)
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<Parent, T>) -> T? {
        value?[keyPath: keyPath]
    }
}

extension ParentReference {
    /// Contains the full model if present. This is the case if the server sent the full model instead of only its ID or if this instance was initialized using an instance of `Model`.
    var value: Parent? {
        boxedValue?.value
    }
}

extension ParentReference: Codable {
    private enum CodingKeys: String, CodingKey {
            case id
        }
    
    public init(from decoder: Decoder) throws {
        if
            let value = try? Parent(from: decoder),
            let id = value.id
        {
            // The whole parent was set. Save it in `value`.
            self.boxedValue = .init(value)
            self.id = id
            return
        }
        
        // Only the ID was sent. Save it in `id`.
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Parent.IDValue.self, forKey: .id)
    }
    
    public func encode(to encoder: Encoder) throws {
        func saveOnlyID() throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
        }
        
        if let value = value, value.id != nil {
            do {
                try value.encode(to: encoder)
            } catch {
                try saveOnlyID()
            }
        } else {
            try saveOnlyID()
        }
    }
}

extension ParentReference: Equatable where Parent.IDValue: Equatable {
    public static func == (lhs: ParentReference<Parent>, rhs: ParentReference<Parent>) -> Bool {
        lhs.id == rhs.id
    }
}

extension ParentReference: Hashable where Parent.IDValue: Hashable {
    public func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}

/// Allows a struct to have a property containing its own type
private class Boxed<T> {
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
}

extension Boxed: Equatable where T: Equatable {
    static func == (lhs: Boxed<T>, rhs: Boxed<T>) -> Bool {
        lhs.value == rhs.value
    }
}

extension Boxed: Hashable where T: Hashable {
    func hash(into hasher: inout Hasher) {
        value.hash(into: &hasher)
    }
}

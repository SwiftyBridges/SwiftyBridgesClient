import Foundation

/// Allows a struct to have a property containing its own type
///
/// The folowing struct results in a compiler error because a struct cannot store a property of its own type:
///
///     struct Person {
///       var parent: Person?
///     }
///
/// Using `@Indirect` solves the problem:
///
///     struct Person {
///       @Indirect var parent: Person?
///     }
@propertyWrapper
public struct Indirect<T> {
    private class Boxed<T> {
        let value: T
        
        init(_ value: T) {
            self.value = value
        }
    }
    
    private var _wrappedValue: Boxed<T>
    
    public init(wrappedValue: T) {
        _wrappedValue = .init(wrappedValue)
    }
    
    public var wrappedValue: T {
        get {
            _wrappedValue.value
        }
        
        set {
            _wrappedValue = .init(newValue)
        }
    }
}

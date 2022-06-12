import Foundation

/// Contains flags and infos about the current execution environment
enum Environment {
    /// If true, signals to a ``FluentModelStruct`` that only those properties that are decoded by Fluent should be encoded
    @TaskLocal static var encodingForFluent = false
}

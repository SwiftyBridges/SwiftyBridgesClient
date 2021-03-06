import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Performs API method calls of SwiftyBridge APIs
public class BridgeClient {
    /// The `BridgeClient` instance used by default
    public static let shared: BridgeClient = .init(urlSession: .shared)
    
    private let urlSession: URLSession
    
    /// Default initializer
    /// - Parameter urlSession: The `URLSession` to be used for all API method calls
    public init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
}

// MARK: - Public Members

private let jsonEncoder = JSONEncoder()
private let jsonDecoder = JSONDecoder()

extension BridgeClient {
    /// Performs the given API method call
    /// - Parameters:
    ///   - call: The API method call generated by SwiftyBridges to be performed
    ///   - baseRequest: This request is used as the basis for the request sent to perform the API method call
    /// - Returns: The return value of the API method call
    public func perform<Call: APIMethodCall>(_ call: Call, baseRequest: URLRequest) async throws -> Call.ReturnType {
        
        var request = baseRequest
        request.setValue(Call.typeName, forHTTPHeaderField: "API-Type")
        request.setValue(Call.methodID, forHTTPHeaderField: "API-Method")
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try jsonEncoder.encode(call)
        let (data, response) = try await urlSession.data(for: request)
        
        guard let response = response as? HTTPURLResponse else {
            throw UnknownError()
        }
        switch response.statusCode {
        case 200..<299:
            break
        default:
            let errorResponse = try? jsonDecoder.decode(ErrorResponse.self, from: data)
            throw HTTPError(
                reason: errorResponse?.reason,
                response: response
            )
        }
        
        return try jsonDecoder.decode(Call.ReturnType.self, from: data)
    }
}

struct UnknownError: LocalizedError {
    var errorDescription: String? {
        NSLocalizedString("An unknown error occurred", comment: "Error message")
    }
}

/// Used to decode the response body if the server has reported an error
private struct ErrorResponse: Codable {
    var error: Bool
    var reason: String
}

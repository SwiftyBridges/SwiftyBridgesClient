import Foundation

public class BridgeClient {
    public static let shared: BridgeClient = .init(urlSession: .shared)
    
    private let urlSession: URLSession
    
    public init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
}

// MARK: - Public Members

private let jsonEncoder = JSONEncoder()
private let jsonDecoder = JSONDecoder()

extension BridgeClient {
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

private struct ErrorResponse: Codable {
    var error: Bool
    var reason: String
}

public struct HTTPError: LocalizedError {
    public var reason: String?
    public var response: HTTPURLResponse
    
    public var statusCode: Int {
        response.statusCode
    }
    
    public var errorDescription: String? {
        (reason ?? HTTPURLResponse.localizedString(forStatusCode: statusCode)) + " (\(statusCode))"
    }
    
    public var isUnauthorizedError: Bool {
        statusCode == 401
    }
}

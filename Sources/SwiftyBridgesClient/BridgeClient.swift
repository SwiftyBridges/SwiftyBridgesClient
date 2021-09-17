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
            throw HTTPError(statusCode: response.statusCode)
        }
        
        return try jsonDecoder.decode(Call.ReturnType.self, from: data)
    }
}

struct UnknownError: LocalizedError {}

public struct HTTPError: LocalizedError {
    public var statusCode: Int
    
    public var errorDescription: String? {
        NSLocalizedString("HTTP error", comment: "") + " \(statusCode)"
    }
}

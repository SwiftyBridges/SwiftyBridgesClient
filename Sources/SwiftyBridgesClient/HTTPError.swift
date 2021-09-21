//
//  HTTPError.swift
//  
//
//  Created by Stephen Kockentiedt on 21.09.21.
//

import Foundation

/// Thrown by an API method call if the server reports an error
public struct HTTPError: LocalizedError {
    /// The reason for the error as reported by the server
    public var reason: String?
    
    /// The response to the API method call
    public var response: HTTPURLResponse
    
    /// The HTTP status code of the response to the API method call
    public var statusCode: Int {
        response.statusCode
    }
    
    public var errorDescription: String? {
        (reason ?? HTTPURLResponse.localizedString(forStatusCode: statusCode)) + " (\(statusCode))"
    }
    
    /// Is true if the server returned the status code 401. This is usually the case if the user is not logged in or the login has expired.
    public var isUnauthorizedError: Bool {
        statusCode == 401
    }
}

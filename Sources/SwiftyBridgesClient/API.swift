//
//  API.swift
//  API
//
//  Created by Stephen Kockentiedt on 17.09.21.
//

import Foundation

public protocol API {
    init(baseRequest: URLRequest, client: BridgeClient)
}

extension API {
    public init(url: URL, client: BridgeClient = .shared) {
        self.init(baseRequest: URLRequest(url: url), client: client)
    }
    
    public init(url: URL, bearerToken: String, client: BridgeClient = .shared) {
        var request = URLRequest(url: url)
        request.addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        self.init(baseRequest: request, client: client)
    }
}

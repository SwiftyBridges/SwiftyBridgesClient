//
//  API.swift
//  API
//
//  Created by Stephen Kockentiedt on 17.09.21.
//

import Foundation

open class API {
    private let baseRequest: URLRequest
    private let client: BridgeClient
    
    private let errorContinuations = Continuations<Error>()
    
    public init(baseRequest: URLRequest, client: BridgeClient = .shared) {
        self.baseRequest = baseRequest
        self.client = client
    }
    
    public func perform<Call: APIMethodCall>(_ call: Call) async throws -> Call.ReturnType {
        do {
            return try await client.perform(call, baseRequest: baseRequest)
        } catch {
            await errorContinuations.yield(error)
            throw error
        }
    }
}

extension API {
    public convenience init(url: URL, client: BridgeClient = .shared) {
        self.init(baseRequest: URLRequest(url: url), client: client)
    }
    
    public convenience init(url: URL, bearerToken: String, client: BridgeClient = .shared) {
        var request = URLRequest(url: url)
        request.addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        self.init(baseRequest: request, client: client)
    }
}

extension API {
    public var errors: AsyncStream<Error> {
        AsyncStream { continuation in
            Task {
                await errorContinuations.add(continuation)
            }
        }
    }
}

actor Continuations<Element> {
    private var continuationByID: [UUID: AsyncStream<Element>.Continuation] = [:]
    
    deinit {
        continuationByID.values.forEach { $0.finish() }
    }
    
    func add(_ continuation: AsyncStream<Element>.Continuation) {
        let id = UUID()
        continuationByID[id] = continuation
        continuation.onTermination = { @Sendable [weak self] _ in
            guard let self = self else { return }
            Task {
                await self.remove(continuationWithID: id)
            }
        }
    }
    
    func yield(_ value: Element) {
        for continuation in continuationByID.values {
            continuation.yield(value)
        }
    }
    
    private func remove(continuationWithID id: UUID) {
        continuationByID[id]?.finish()
        continuationByID[id] = nil
    }
}

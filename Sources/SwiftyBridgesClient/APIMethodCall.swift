//
//  File.swift
//  File
//
//  Created by Stephen Kockentiedt on 16.09.21.
//

import Foundation

public protocol APIMethodCall: Encodable {
    associatedtype ReturnType: Decodable
    static var typeName: String { get }
    static var methodID: String { get }
}

public struct NoReturnValue: Codable {
    public init() {}
    public init(from decoder: Decoder) throws {}
    public func encode(to encoder: Encoder) throws {}
}

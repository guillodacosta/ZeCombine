//
//  APICall.swift
//

import Foundation

public typealias HTTPCode = Int
public typealias HTTPCodes = Range<HTTPCode>

public protocol APICall {
    var headers: [String: String]? { get }
    var method: String { get }
    var path: String { get }
    
    func body() throws -> Data?
}

public enum APIError: Swift.Error {
    case httpCode(HTTPCode)
    case imageDeserialization
    case invalidURL
    case unexpectedResponse
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .httpCode(code): return "Unexpected HTTP code: \(code)"
        case .imageDeserialization: return "Cannot deserialize image from Data"
        case .invalidURL: return "Invalid URL"
        case .unexpectedResponse: return "Unexpected response from the server"
        }
    }
}

public extension APICall {
    func urlRequest(baseURL: String) throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        request.httpBody = try body()
        return request
    }
}

public extension HTTPCodes {
    static let success = 200 ..< 300
}

//
//  APICall.swift
//

import Foundation

typealias HTTPCode = Int
typealias HTTPCodes = Range<HTTPCode>

protocol APICall {
    var headers: [String: String]? { get }
    var method: String { get }
    var path: String { get }
    
    func body() throws -> Data?
}

enum APIError: Swift.Error {
    case httpCode(HTTPCode)
    case imageDeserialization
    case invalidURL
    case unexpectedResponse
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .httpCode(code): return "Unexpected HTTP code: \(code)"
        case .imageDeserialization: return "Cannot deserialize image from Data"
        case .invalidURL: return "Invalid URL"
        case .unexpectedResponse: return "Unexpected response from the server"
        }
    }
}

extension APICall {
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

extension HTTPCodes {
    static let success = 200 ..< 300
}

//
//  APIClient.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 06/06/2026.
//


import Foundation

// This handles building request to the API and decoding the returned values
struct APIClient {
    private static let session = URLSession.shared

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    static func request<T: Decodable>(url: URL, method: String = "GET", body: Data? = nil) async throws -> T {
        let request = try buildRequest(url: url, method: method, body: body)

        let (data, response) = try await session.data(for: request)

        try APIError.map(data,response, url: request.url?.absoluteString ?? "")

        return try decoder.decode(T.self, from: data)
    }

    @discardableResult
    static func mutate<T: Decodable>(url: URL, method: String, body: Data? = nil, responseType: T.Type = EmptyResponse.self) async throws -> T {
        let request = try buildRequest(url: url, method: method, body: body)
        
        let (data, response) = try await session.data(for: request)

        try APIError.map(data, response, url: request.url?.absoluteString ?? "")

        if T.self == EmptyResponse.self, data.isEmpty {
            return EmptyResponse() as! T
        }

        return try decoder.decode(T.self, from: data)
    }
    
    @discardableResult
    static func upload(url: URL,method: String, imageData: Data, fileName: String, mimeType: String = "image/jpeg") async throws -> EmptyResponse {
        let boundary = UUID().uuidString
        var request = try buildRequest(url: url, method: method, body: nil)

        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, response) = try await session.data(for: request)

        try APIError.map(data,response,url: request.url?.absoluteString ?? "")

        return EmptyResponse()
    }
    
    static func delete(url: URL) async throws {
        let request = try buildRequest(url: url, method: "DELETE", body: nil)

        let (data, response) = try await session.data(for: request)

        try APIError.map(data, response, url: request.url?.absoluteString ?? "")
    }
    
    static func ping(url: URL) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        
        let apiKey = ProcessInfo.processInfo.environment["COCKTAILS_API_KEY"]
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        let (data, response) = try await session.data(for: request)

        try APIError.map(data,response,url: request.url?.absoluteString ?? "")
    }

    private static func buildRequest(url: URL, method: String, body: Data?) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method

        let apiKey = ProcessInfo.processInfo.environment["COCKTAILS_API_KEY"]
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")

        if let token = try? KeychainAuthStore.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = body

        return request
    }
}

struct EmptyResponse: Decodable {
    init() {}
}

//
//  APIClient.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 06/06/2026.
//


import Foundation

public protocol APIClientProtocol {
    func request<T: Decodable>(url: URL, method: String, body: Data?, headers: [String: String]?) async throws -> T
    func requestData(url: URL, method: String, body: Data?, headers: [String: String]?) async throws -> Data
    func mutate<T: Decodable>(url: URL, method: String, body: Data?, responseType: T.Type) async throws -> T
    func upload(url: URL, method: String, imageData: Data, fileName: String, mimeType: String) async throws -> EmptyResponse
    func delete(url: URL) async throws
    func ping(url: URL) async throws
}

struct APIClient: APIClientProtocol {
    private let session: URLSession = .shared
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    func request<T: Decodable>(url: URL, method: String = "GET", body: Data? = nil, headers: [String: String]? = nil) async throws -> T {
        let request = try buildRequest(url: url, method: method, body: body, headers: headers)
        let (data, response) = try await perform(request)
        try APIError.map(data, response, url: request.url?.absoluteString ?? "")
        return try decoder.decode(T.self, from: data)
    }
    
    func requestData(url: URL, method: String = "GET", body: Data? = nil, headers: [String: String]? = nil) async throws -> Data {
        let request = try buildRequest(url: url, method: method, body: body, headers: headers)
        let (data, response) = try await perform(request)
        try APIError.map(data, response, url: request.url?.absoluteString ?? "")
        return data
    }
    
    func mutate<T: Decodable>(url: URL, method: String, body: Data? = nil, responseType: T.Type = EmptyResponse.self) async throws -> T {
        let request = try buildRequest(url: url, method: method, body: body, contentType: "application/json")
        let (data, response) = try await perform(request)
        try APIError.map(data, response, url: request.url?.absoluteString ?? "")
        if T.self == EmptyResponse.self, data.isEmpty {
            return EmptyResponse() as! T
        }
        return try decoder.decode(T.self, from: data)
    }
    
    func upload(url: URL, method: String, imageData: Data, fileName: String, mimeType: String = "image/jpeg") async throws -> EmptyResponse {
        let boundary = UUID().uuidString
        let contentType = "multipart/form-data; boundary=\(boundary)"
        var request = try buildRequest(url: url, method: method, body: nil, contentType: contentType)
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        let (data, response) = try await perform(request)
        try APIError.map(data, response, url: request.url?.absoluteString ?? "")
        return EmptyResponse()
    }
    
    func delete(url: URL) async throws {
        let request = try buildRequest(url: url, method: "DELETE", body: nil)
        let (data, response) = try await perform(request)
        try APIError.map(data, response, url: request.url?.absoluteString ?? "")
    }
    
    func ping(url: URL) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        let apiKey = ServiceConfig.apiKey
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        let (data, response) = try await perform(request)
        try APIError.map(data, response, url: request.url?.absoluteString ?? "")
    }
    
    private func buildRequest(url: URL, method: String, body: Data?, headers: [String: String]? = nil, contentType: String? = nil) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        let apiKey = ServiceConfig.apiKey
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        if let token = try? KeychainAuthStore.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Override or add custom headers
        if (headers != nil) {
            headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        }
        
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.httpBody = body
        return request
    }
    
    private func perform(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}

public struct EmptyResponse: Decodable {
    init() {}
}


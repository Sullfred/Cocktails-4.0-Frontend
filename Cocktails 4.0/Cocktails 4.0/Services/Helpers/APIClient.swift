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

        let (data, response) = try await perform(request)

        try APIError.map(data,response, url: request.url?.absoluteString ?? "")

        return try decoder.decode(T.self, from: data)
    }
    
    static func requestData(url: URL, method: String = "GET", body: Data? = nil) async throws -> Data {
        let request = try buildRequest(url: url, method: method, body: body)

        let (data, response) = try await perform(request)

        try APIError.map(data, response, url: request.url?.absoluteString ?? "")

        return data
    }

    @discardableResult
    static func mutate<T: Decodable>(url: URL, method: String, body: Data? = nil, responseType: T.Type = EmptyResponse.self) async throws -> T {
        let request = try buildRequest(url: url, method: method, body: body, contentType: "application/json")
        
        let (data, response) = try await perform(request)

        try APIError.map(data, response, url: request.url?.absoluteString ?? "")

        if T.self == EmptyResponse.self, data.isEmpty {
            return EmptyResponse() as! T
        }

        return try decoder.decode(T.self, from: data)
    }
    
    @discardableResult
    static func upload(url: URL,method: String, imageData: Data, fileName: String, mimeType: String = "image/jpeg") async throws -> EmptyResponse {
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

        try APIError.map(data,response,url: request.url?.absoluteString ?? "")

        return EmptyResponse()
    }
    
    static func delete(url: URL) async throws {
        let request = try buildRequest(url: url, method: "DELETE", body: nil)

        let (data, response) = try await perform(request)

        try APIError.map(data, response, url: request.url?.absoluteString ?? "")
    }
    
    static func ping(url: URL) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        
        let apiKey = ServiceConfig.apiKey
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        let (data, response) = try await perform(request)

        try APIError.map(data,response,url: request.url?.absoluteString ?? "")
    }

    private static func buildRequest(url: URL, method: String, body: Data?, contentType: String? = nil) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method

        let apiKey = ServiceConfig.apiKey
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        if let token = try? KeychainAuthStore.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.httpBody = body
        
        return request
    }

    private static func perform(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}

struct EmptyResponse: Decodable {
    init() {}
}

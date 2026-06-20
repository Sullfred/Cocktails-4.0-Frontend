//
//  APIError.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 06/06/2026.
//

import Foundation

enum APIError: Error, LocalizedError {
    case networkFailure(Error)
    case httpError(statusCode: Int, message: String?)
    case decodingFailed(String)
    case serverMessage(String)
    case unauthorized(String?)
    case notFound

    var errorDescription: String? {
        switch self {
        case .networkFailure(let e):
            return e.localizedDescription
        case .httpError(let code, let msg): 
            return "HTTP \(code): \(msg ?? "Unknown")"
        case .decodingFailed(let desc): 
            return "Decoding failed: \(desc)"
        case .serverMessage(let msg):
            return msg
        case .unauthorized(let msg): 
            return msg ?? "Authentication required"
        case .notFound: 
            return "Item not found"
        }
    }

    static func map(_ data: Data?, _ response: URLResponse, url: String) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.httpError(statusCode: 0, message: "No HTTP response for \(url)")
        }

        if !(200...299).contains(httpResponse.statusCode) {
            let msg =
                ((try? JSONSerialization.jsonObject(with: data ?? Data())) as? [String: String])?["reason"]
                ?? String(data: data ?? Data(), encoding: .utf8)
                ?? "Server error"

            if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                throw APIError.unauthorized(msg)
            }
            
            if httpResponse.statusCode == 404 {
                throw APIError.notFound
            }

            throw APIError.serverMessage(msg)
        }
    }
}

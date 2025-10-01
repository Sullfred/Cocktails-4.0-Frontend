//
//  ErrorHandler.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 27/09/2025.
//

import Foundation

enum ErrorOutput: Error, LocalizedError {
    case networkError(Error)
    case serverError(statusCode: Int, message: String? = nil)
    case decodingError(Error)
    case encodingError(message: String)
    case unauthorized
    case notFound
    case unknown(Error?)
    case customError(message: String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let err):
            return "Network error: \(err.localizedDescription)"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message ?? "No details")"
        case .decodingError(let err):
            return "Failed to process data: \(err.localizedDescription)"
        case .encodingError(let message):
            return "Encoding error: \(message)"
        case .unauthorized:
            return "Wrong Username or Password."
        case .notFound:
            return "Requested resource was not found."
        case .unknown(let err):
            return "An unknown error occurred: \(err?.localizedDescription ?? "No details")"
        case .customError(let message):
            return "\(message)"
        }
    }
}

struct ErrorHandler {
    static func normalize(_ error: Error) -> ErrorOutput {
        if let err = error as? ErrorOutput {
            return err
        } else if (error as NSError).domain == NSURLErrorDomain {
            return .networkError(error)
        } else {
            return .unknown(error)
        }
    }
    
    // Func used for showing errors to user using the toast view
    static func handle(_ error: Error, showToUser: Bool = true) {
        let errorOutput = normalize(error)
        
        if showToUser {
            switch errorOutput {
            case .networkError, .unauthorized, .serverError:
                ToastManager.shared.show(style: .error, message: errorOutput.localizedDescription)
            default:
                break
            }
        }
        
        // print errors for debugging during dev - remove later
        print("Error: \(errorOutput.localizedDescription)")
    }
    
    // Handle errors from the server
    // Parse the message to a string
    static func parseErrorMessage(from data: Data?) -> String? {
        guard let data = data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    // Map the response from the server to a status code and handle the resonse depending on the code
    static func mapHTTPResponse(_ response: URLResponse?, data: Data?) -> ErrorOutput? {
        guard let httpResponse = response as? HTTPURLResponse else {
            return .serverError(statusCode: -1, message: "Invalid response")
        }
        
        let statusCode = httpResponse.statusCode
        
        switch statusCode {
        case 200...299:
            return nil
        case 401:
            return .unauthorized
        case 404:
            return .notFound
        default:
            let message = parseErrorMessage(from: data)
            return .serverError(statusCode: statusCode, message: message)
        }
    }
}

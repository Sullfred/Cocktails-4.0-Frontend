//
//  UserAPI.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 26/09/2025.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class UserService: ObservableObject {
    private let serviceURL = ServiceConfig.baseURL.appending(path: Endpoints.user)
    
    init() {}
    
    func createUser(username: String, password: String, confirmPassword: String) async throws {
        let dto = CreateUserDTO(username: username, password: password, confirmPassword: confirmPassword)
        let url = serviceURL.appending(path: "register")
        
        // Request info
        var request = createRequestHeader(url: url, method: "POST", setApplicationField: true)
        
        // Request body
        let body = try JSONEncoder().encode(dto)
        request.httpBody = body
        
        // Await and handle response from server
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ErrorOutput.serverError(statusCode: 500, message: "No response from server")
        }
        if httpResponse.statusCode == 409 {
            var errorMessage: String = "Failed to register user"
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let reason = json["reason"] as? String {
                errorMessage = reason
            } else if let string = String(data: data, encoding: .utf8), !string.isEmpty {
                errorMessage = string
            }
            throw ErrorOutput.customError(message: errorMessage)
        }
        if !(200...299).contains(httpResponse.statusCode) {
            // Decode error message from server
            var errorMessage: String = "Failed to register user"
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let reason = json["reason"] as? String {
                errorMessage = reason
            } else if let string = String(data: data, encoding: .utf8), !string.isEmpty {
                errorMessage = string
            }
            throw ErrorOutput.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
    }
    
    func login(username: String, password: String) async throws -> LoginResponse {
        let url = serviceURL.appending(path: "login")
        
        // Request info
        var request = createRequestHeader(url: url, method: "POST")
        
        // Encode username and password in Basic Auth header
        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: .utf8) else {
            throw ErrorOutput.encodingError(message: "Failed to encode credentials")
        }
        let base64Login = loginData.base64EncodedString()
        request.setValue("Basic \(base64Login)", forHTTPHeaderField: "Authorization")
        
        // Await and handle response from server
        let (data, response) = try await URLSession.shared.data(for: request)
        if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
            throw error
        }
        
        let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        return loginResponse
    }
    
    func logout(userToken: String) async throws {
        let url = serviceURL.appending(path: "logout")
        
        // Request info
        var request = createRequestHeader(url: url, method: "POST", token: userToken)

        // Await and handle response from server
        let (data, response) = try await URLSession.shared.data(for: request)

        // If the token is already invalid/expired, logout should still be considered successful
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200...299:
                return
            case 401, 403, 404:
                // Token missing, expired, or already deleted on server
                // Treat as successful logout to allow client cleanup
                return
            default:
                // Handle unexpected errors
                if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
                    throw error
                }
            }
        }
    }
    
    func deleteUser(userToken: String) async throws {
        let url = serviceURL.appending(path: "me")
        
        // Request info
        var request = createRequestHeader(url: url, method: "DELETE", token: userToken)
        
        // Await and handle response from server
        let (data, response) = try await URLSession.shared.data(for: request)
        if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
            throw error
        }
    }
    
    func updateUsername(userToken: String, newUsername: String) async throws {
        let url = serviceURL.appending(path: "updateUsername")
        let dto = UpdateUsernameDTO(newUsername: newUsername)
        
        // Request info
        var request = createRequestHeader(url: url, method: "PATCH", token: userToken, setApplicationField: true)
        
        let body = try JSONEncoder().encode(dto)
        request.httpBody = body
        
        // Await and handle response from server
        let (data, response) = try await URLSession.shared.data(for: request)
        if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
            throw error
        }
    }
    
    // Update password function
    func updatePassword(userToken: String, currentPassword: String, newPassword: String, confirmNewPassword: String) async throws {
        let url = serviceURL.appending(path: "updatePassword")
        let dto = UpdatePasswordDTO(currentPassword: currentPassword, newPassword: newPassword, confirmNewPassword: confirmNewPassword)
        
        // Request info
        var request = createRequestHeader(url: url, method: "PATCH", token: userToken, setApplicationField: true)
        
        let body = try JSONEncoder().encode(dto)
        request.httpBody = body
        
        // Await and handle response from server
        let (data, response) = try await URLSession.shared.data(for: request)
        if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
            throw error
        }
    }
    
    func verifyUser(userToken: String) async throws {
        let url = serviceURL.appending(path: "verifyToken")
        
        // Request info
        var request = createRequestHeader(url: url, method: "GET", token: userToken)
        
        // Await and handle response from server
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let HTTPURLResponse = response as? HTTPURLResponse {
            let httpCode = HTTPURLResponse.statusCode
            
            if httpCode != 200 {
                throw ErrorHandler.mapHTTPResponse(response, data: data)!
            }
        }
    }
}

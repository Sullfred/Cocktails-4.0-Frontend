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
    static let shared = UserService()
    private let serviceURL = ServiceConfig.baseURL.appending(path: Endpoints.user)
    
    private init() {}
    
    func createUser(username: String, password: String, confirmPassword: String) async throws {
        let dto = CreateUserDTO(username: username, password: password, confirmPassword: confirmPassword)
        let url = serviceURL.appending(path: "register")
        
        // Request info
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

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
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        
        // Await and handle response from server
        let (data, response) = try await URLSession.shared.data(for: request)
        if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
            throw error
        }
    }
    
    func deleteUser(userToken: String) async throws {
        let url = serviceURL.appending(path: "me")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")

        // Await and handle response from server
        let (data, response) = try await URLSession.shared.data(for: request)
        if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
            throw error
        }
    }
    
    func updateUsername(userToken: String, newUsername: String) async throws {
        let url = serviceURL.appending(path: "updateUsername")
        let dto = UpdateUsernameDTO(newUsername: newUsername)
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = try JSONEncoder().encode(dto)
        request.httpBody = body
        
        // Await and handle response from server
        let (data, response) = try await URLSession.shared.data(for: request)
        if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
            throw error
        }
    }
    
    func updatePassword(userToken: String, currentPassword: String, newPassword: String, confirmNewPassword: String) async throws {
        let url = serviceURL.appending(path: "updatePassword")
        let dto = UpdatePasswordDTO(currentPassword: currentPassword, newPassword: newPassword, confirmNewPassword: confirmNewPassword)
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = try JSONEncoder().encode(dto)
        request.httpBody = body
        
        // Await and handle response from server
        let (data, response) = try await URLSession.shared.data(for: request)
        if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
            throw error
        }
    }
}

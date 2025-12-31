//
//  AdminService.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 31/10/2025.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class AdminService: ObservableObject {
    private let userServiceURL = ServiceConfig.baseURL.appending(path: Endpoints.user)
    private let cocktailServiceURL = ServiceConfig.baseURL.appending(path: Endpoints.cocktails)
    
    init() {}
    
    // Check if the server is reachable
    func checkServerConnection() async throws -> Bool {
        let url = ServiceConfig.baseURL.appending(path: "ping")
        
        // Request info
        var request = createRequestHeader(url: url, method: "GET")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return false
        }
        return true
    }
    
    // fetch users
    func fetchUsers(userToken: String) async throws -> [fetchPublicUserDTO] {
        let url = userServiceURL.appending(path: "fetchUsers")
        
        // Request info
        var request = createRequestHeader(url: url, method: "GET", token: userToken)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
            throw error
        }
        
        let users = try JSONDecoder().decode([fetchPublicUserDTO].self, from: data)
        return users
    }
    
    func updateUserRole(userId: UUID, newRole: UserRole, userToken: String) async throws {
        let url = userServiceURL.appending(path: "updateUserRole")
        let dto = UpdateUserRoleDTO(id: userId, role: newRole)
        
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
    
    func deleteCocktail(userToken: String, cocktailIds: [String]) async throws {
        
        for cocktailId in cocktailIds {
            let url = cocktailServiceURL.appending(path: cocktailId)
            
            var request = createRequestHeader(url: url, method: "DELETE", token: userToken)
            
            // Await and handle response from server
            let (data, response) = try await URLSession.shared.data(for: request)
            if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
                throw error
            }
        }
    }
}

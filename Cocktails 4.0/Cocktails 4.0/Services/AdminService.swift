//
//  AdminService.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 31/10/2025.
//

import Foundation
import SwiftData
import SwiftUI

class AdminService: ObservableObject {
    private let userServiceURL = ServiceConfig.baseURL.appending(path: Endpoints.user)
    private let cocktailServiceURL = ServiceConfig.baseURL.appending(path: Endpoints.cocktails)
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func fetchUsers() async throws -> [fetchPublicUserDTO] {
        let url = userServiceURL.appending(path: "fetchUsers")
        let users: [fetchPublicUserDTO] = try await apiClient.request(url: url, method: "GET", body: nil, headers: nil)
        return users
    }
    
    func updateUserRole(userId: UUID, newRole: UserRole) async throws {
        let url = userServiceURL.appending(path: "updateUserRole")
        let dto = UpdateUserRoleDTO(id: userId, role: newRole)
        let body = try JSONEncoder().encode(dto)
        
        let _ = try await apiClient.mutate(
            url: url,
            method: "PUT",
            body: body,
            responseType: EmptyResponse.self
        )
    }
    
    func deleteCocktail(cocktailIds: [String]) async throws {
        for cocktailId in cocktailIds {
            let url = cocktailServiceURL.appending(path: cocktailId)
            let _ = try await apiClient.mutate(
                url: url,
                method: "DELETE",
                body: nil,
                responseType: EmptyResponse.self
            )
        }
    }
    
    func checkServerConnection() async throws -> Bool {
        let url = ServiceConfig.baseURL.appending(path: Endpoints.cocktails)
        do {
            try await apiClient.ping(url: url)
            return true
        } catch {
            return false
        }
    }
}

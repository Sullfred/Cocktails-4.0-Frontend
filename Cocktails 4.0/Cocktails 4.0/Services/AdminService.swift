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
    
    init() {}
    
    // fetch users
    func fetchUsers() async throws -> [fetchPublicUserDTO] {
        let url = userServiceURL.appending(path: "fetchUsers")
        
        let users: [fetchPublicUserDTO] = try await APIClient.request(url: url)
        return users
    }
    
    func updateUserRole(userId: UUID, newRole: UserRole) async throws {
        let url = userServiceURL.appending(path: "updateUserRole")
        let dto = UpdateUserRoleDTO(id: userId, role: newRole)
        let body = try JSONEncoder().encode(dto)
        
        try await APIClient.mutate(
            url: url,
            method: "PUT",
            body: body
        )
    }
    
    func deleteCocktail(cocktailIds: [String]) async throws {
        for cocktailId in cocktailIds {
            let url = cocktailServiceURL.appending(path: cocktailId)
            
            try await APIClient.mutate(
                url: url,
                method: "DELETE"
            )
        }
    }
    
    func checkServerConnection() async throws -> Bool {
        let url = ServiceConfig.baseURL.appending(path: Endpoints.cocktails)
        
        do {
            try await APIClient.ping(url: url)
            return true
        } catch {
            return false
        }
    }
}

//
//  AdminViewModel.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 17/10/2025.
//

import Foundation
import SwiftData

@MainActor
class AdminViewModel: ObservableObject {
    @Published var isConnected: Bool = false
    @Published var isCheckingConnection = false
    @Published var isLoading = false
    @Published var isSuccess = false
    
    private let dependencies: AppDependencies
    
    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }
    
    func fetchUsers() async -> [fetchPublicUserDTO] {
        isLoading = true
        var users: [fetchPublicUserDTO] = []
        
        defer {
            isLoading = false
        }
        
        do {
            users = try await dependencies.adminService.fetchUsers()
        } catch {
            ErrorHandler.handle(error)
        }
        
        return users
    }
    
    func updateUserRole(userID: UUID, newRole: UserRole) async -> Bool {
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        do {
            try await dependencies.adminService.updateUserRole(userId: userID, newRole: newRole)
            return true
        } catch {
            ErrorHandler.handle(error)
            return false
        }
    }
    
    func deleteCocktails(cocktailIds: [String]) async -> Bool {
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        do {
            try await dependencies.adminService.deleteCocktail(cocktailIds: cocktailIds)
            return true
        } catch {
            ErrorHandler.handle(error)
            return false
        }
    }
    
    func checkServerConnection() async {
        isCheckingConnection = true
        defer {
            isCheckingConnection = false
        }
        
        do {
            isConnected = try await dependencies.adminService.checkServerConnection()
        } catch {
            isConnected = false
        }
    }
}

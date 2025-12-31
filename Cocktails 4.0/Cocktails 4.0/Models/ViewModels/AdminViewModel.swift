//
//  AdminViewModel.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 17/10/2025.
//

import Foundation
import SwiftData
import KeychainSwift

@MainActor
class AdminViewModel: ObservableObject {
    @Published var isConnected: Bool = false
    @Published var isCheckingConnection = false
    @Published var isLoading = false
    @Published var isSuccess = false
    @Published var errorMessage: String?

    private let service: AdminService
    
    init() {
        self.service = AdminService()
    }

    func fetchUsers() async -> [fetchPublicUserDTO] {
        isLoading = true
        errorMessage = nil
        var users: [fetchPublicUserDTO] = []
        
        // Get userToken
        let keychain = KeychainSwift()
        guard let token = keychain.get("userToken")
        else {
            isLoading = false
            
            return []
        }
        
        do {
            users = try await service.fetchUsers(userToken: token)
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
        }
        isLoading = false
        return users
    }

    func updateUserRole(userID: UUID, newRole: UserRole) async -> Bool {
        isLoading = true
        
        // Get userToken
        let keychain = KeychainSwift()
        guard let token = keychain.get("userToken")
        else {
            isLoading = false
            
            return false
        }
        
        do {
            try await service.updateUserRole(userId: userID, newRole: newRole, userToken: token)
            
            isLoading = false
            return true
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
            isLoading = false
            
            return false
        }
    }
    
    func deleteCocktails(cocktailIds: [String]) async -> Bool {
        isLoading = true

        
        // Get userToken
        let keychain = KeychainSwift()
        guard let token = keychain.get("userToken")
        else {
            isLoading = false
            
            return false
        }
        
        do {
            try await service.deleteCocktail(userToken: token, cocktailIds: cocktailIds)
            
            isLoading = false
            return true
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
            isLoading = false
            
            return false
        }
    }
    
    func checkServerConnection() async {
            isCheckingConnection = true
            defer { isCheckingConnection = false }
            
            do {
                isConnected = try await service.checkServerConnection()
            } catch {
                isConnected = false
            }
        }
}

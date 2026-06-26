//
//  UserViewModel.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/09/2025.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class UserViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: LoggedInUser?
    @Published var showLogin = false
    @Published var authState: AuthState = .unknown

    private let dependencies: AppDependencies
    private let userDefaultsKey = "loggedInUser"
    
    var isLoggedIn: Bool {
        currentUser?.authState == .authenticated
    }
    
    var formIsValid: Bool {
        !username.isEmpty && password.count >= 6
    }
    
    var canCreateCocktails: Bool {
        currentUser?.role == .creator || currentUser?.role == .admin
    }
    
    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        
        loadPersistedSession()
        if currentUser != nil {
            Task {
                await verifyTokenStatus()
            }
        }
    }

    // Auth Actions
    func login() async -> Bool {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
            password = ""
        }

        do {
            let response = try await dependencies.userService.login(
                username: username,
                password: password
            )

            try KeychainAuthStore.shared.saveToken(response.token)

            let user = LoggedInUser(
                id: response.user.id,
                username: response.user.username,
                role: response.user.role,
                authState: .authenticated
            )

            currentUser = user
            authState = .authenticated

            persistCurrentUser()
            showLogin = false

        } catch {
            ErrorHandler.handle(error)
            authState = .unknown
            return false
        }
        
        return true
    }

    func logout() async -> Bool {
        do {
            try await dependencies.userService.logout()
        } catch {
            return false
        }

        clearSession()
        
        return true
    }

    func deleteUser() async -> Bool {
        do {
            try await dependencies.userService.deleteUser()
        } catch {
            ErrorHandler.handle(error)
            return false
        }

        clearSession()
        return true
    }

    // Profile Updates
    func updateUsername(_ newUsername: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await dependencies.userService.updateUsername(newUsername)

            currentUser?.username = newUsername
            persistCurrentUser()

            return true
        } catch {
            ErrorHandler.handle(error)
            return false
        }
    }

    func updatePassword(current: String, new: String, confirm: String) async -> Bool {
        guard new == confirm else {
            errorMessage = "Passwords do not match"
            return false
        }

        isLoading = true
        errorMessage = nil
        defer {
            isLoading = false
        }

        do {
            try await dependencies.userService.updatePassword(current: current, new: new, confirm: confirm)
            return true
        } catch {
            ErrorHandler.handle(error)
            return false
        }
    }

    func verifyTokenStatus() async {
        if authState == .unknown {
            return
        }
        
        do {
            let token = try KeychainAuthStore.shared.getToken()
            if token.isEmpty {
                handleExpiredSession()
                return
            }
            
            try await dependencies.userService.verifyToken(token)
            authState = .authenticated
        } catch APIError.unauthorized {
            handleExpiredSession()
        } catch APIError.notFound {
            handleExpiredSession()
        } catch KeyChainError.getTokenError {
            currentUser?.authState = .expired
            authState = .expired
            persistCurrentUser()
        } catch {
            ErrorHandler.handle(error)
        }
    }
    
    func syncPendingActions() async {
        do {
            try await dependencies.pendingActionCoordinator.processAllPendingActions()
        } catch {
            ErrorHandler.handle(error)
        }
    }

    // Helpers
    private func persistCurrentUser() {
        guard let currentUser else { return }

        do {
            try UserSessionStore.shared.saveUser(currentUser)
        } catch {
            ErrorHandler.handle(error)
        }
    }

    private func loadPersistedSession() {
        guard let user = try? UserSessionStore.shared.getUser()
        else {
            return
        }

        currentUser = user
        authState = user.authState
    }

    private func clearSession() {
        username = ""
        password = ""
        currentUser = nil
        authState = .unknown
        
        UserSessionStore.shared.deleteUser()
        
        do {
            try KeychainAuthStore.shared.deleteToken()
        } catch {
            ErrorHandler.handle(error)
        }
    }

    private func handleExpiredSession() {
        currentUser?.authState = .expired
        authState = .expired
        persistCurrentUser()

        do {
            try KeychainAuthStore.shared.deleteToken()
        } catch {
            ErrorHandler.handle(error)
        }
    }
}

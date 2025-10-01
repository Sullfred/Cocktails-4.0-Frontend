//
//  RegisterViewModel.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/09/2025.
//

import SwiftUI

@MainActor
class RegisterViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var showPassword: Bool = false
    @Published var showConfirmPassword: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var didRegister: Bool = false
    
    var formIsValid: Bool {
        !username.isEmpty &&
        password.count >= 8 &&
        password == confirmPassword
    }
    
    func register() async {
        isLoading = true
        errorMessage = ""
        defer {
            isLoading = false
        }
        do {
            try await UserService.shared.createUser(username: username, password: password, confirmPassword: confirmPassword)
            didRegister = true
        } catch {
            let message = ErrorHandler.normalize(error)
            errorMessage = message.localizedDescription
        }
    }
}

// username: admin
// password: theS3cretAdminPassw0rd

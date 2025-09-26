//
//  LoginViewModel.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/09/2025.
//

import Foundation
import Combine
import KeychainSwift

@MainActor
class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: LoggedInUser? = nil
    
    var formIsValid: Bool {
        !username.isEmpty && !password.isEmpty && password.count >= 6
    }
    
    private let userDefaultsKey = "loggedInUser"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            if let savedUser = try? JSONDecoder().decode(LoggedInUser.self, from: data) {
                currentUser = savedUser
                isLoggedIn = true
            }
        }
    }
    
    func login() async {
        isLoading = true
        errorMessage = nil
        defer {
            isLoading = false
        }
        
        do {
            let response = try await CocktailAPI.shared.login(username: username, password: password)
            
            // save data from response
            let keychain = KeychainSwift()
            let token = response.token
            
            keychain.set(token, forKey: "userToken")
            
            let loggedInUser = LoggedInUser(
                username: response.user.username,
                addPermission: response.user.addPermission,
                editPermissions: response.user.editPermissions,
                adminRights: response.user.adminRights
            )
            if let encoded = try? JSONEncoder().encode(loggedInUser) {
                UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
            }
            currentUser = loggedInUser
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func logout() async {
        let keychain = KeychainSwift()
        guard let token = keychain.get("userToken") else { return}
        do {
            try await CocktailAPI.shared.logout(userToken: token)
        } catch {
            ToastManager.shared.show(style: .error, message: error.localizedDescription)
        }
        
        keychain.delete("userToken")
        isLoggedIn = false
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        
    }
}

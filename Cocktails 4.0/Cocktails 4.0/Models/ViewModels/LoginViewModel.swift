//
//  LoginViewModel.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/09/2025.
//

import Foundation
import Combine
import KeychainSwift
import SwiftData

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
    
    func login(myBarViewModel: MyBarViewModel) async {
        isLoading = true
        errorMessage = nil
        defer {
            isLoading = false
        }
        
        do {
            let response = try await UserService.shared.login(username: username, password: password)
            
            // save data from response
            let keychain = KeychainSwift()
            let token = response.token
            
            keychain.set(token, forKey: "userToken")
            
            let loggedInUser = LoggedInUser(
                id: response.user.id,
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
            
            // Get users personal bar after login
            await myBarViewModel.getPersonalBar()
            
        } catch {
            let message = ErrorHandler.normalize(error)
            errorMessage = message.localizedDescription
        }
    }
    
    func logout(myBarViewModel: MyBarViewModel) async {
        let keychain = KeychainSwift()
        guard let token = keychain.get("userToken")
        else {
            return
        }
        
        do {
            try await UserService.shared.logout(userToken: token)
        } catch {
            ToastManager.shared.show(style: .error, message: error.localizedDescription)
        }
        
        // Delete personal bar from context
        myBarViewModel.changeToGuestBar()
        
        keychain.delete("userToken")
        isLoggedIn = false
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    func deleteUser(context: ModelContext) async {
        let keychain = KeychainSwift()
        guard let token = keychain.get("userToken")
        else {
            return
        }
        
        do {
            try await UserService.shared.deleteUser(userToken: token)
        } catch {
            ToastManager.shared.show(style: .error, message: error.localizedDescription)
        }
        
        // Delete personal bar from context
        let cureentUserId = self.currentUser?.id
        if let bar = try? context.fetch(FetchDescriptor<MyBar>(predicate: #Predicate { $0.userId == cureentUserId })).first {
            context.delete(bar)
            try? context.save()
        }
        
        keychain.delete("userToken")
        isLoggedIn = false
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}

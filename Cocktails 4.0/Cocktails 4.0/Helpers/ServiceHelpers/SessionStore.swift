//
//  SessionStore.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 10/06/2026.
//

import Foundation

protocol SessionStore {
    func saveUser(_ user: LoggedInUser) throws
    func getUser() throws -> LoggedInUser?
    func deleteUser()
}

class UserSessionStore: SessionStore {
    static let shared = UserSessionStore()
    private let userDefaults = UserDefaults.standard
    private let userKey = "loggedInUser"
    
    private init() {}
    
    func saveUser(_ user: LoggedInUser) throws {
        let data = try JSONEncoder().encode(user)
        userDefaults.set(data, forKey: userKey)
    }
    
    func getUser() throws -> LoggedInUser? {
        guard let data = userDefaults.data(forKey: userKey) else {
            return nil
        }
        
        return try JSONDecoder().decode(LoggedInUser.self, from: data)
    }
    
    func deleteUser() {
        userDefaults.removeObject(forKey: userKey)
    }
}

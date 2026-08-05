//
//  AuthStore.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 06/06/2026.
//

import KeychainSwift

protocol AuthStore {
    func saveToken(_ token: String) throws
    func getToken() throws -> String
    func deleteToken() throws
}

class KeychainAuthStore: AuthStore {
    static let shared = KeychainAuthStore()
    private let keychain = KeychainSwift()
    private let tokenKey = "userToken"
    
    private init() {}
    
    func saveToken(_ token: String) throws {
        if keychain.set(token, forKey: tokenKey) {} else {
            throw KeyChainError.saveTokenError
        }
    }
    
    func getToken() throws -> String {
        if let token = keychain.get(tokenKey) {
            return token
        } else {
            throw KeyChainError.getTokenError
        }
    }
    
    func deleteToken() throws {
        if keychain.delete(tokenKey) {} else {
            throw KeyChainError.deleteTokenError
        }
    }
}

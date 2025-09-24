//
//  LoginDTO.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/09/2025.
//

struct LoginRequestDTO: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let token: String
    let user: UserDTO
}

struct UserDTO: Codable {
    let username: String
    let addPermission: Bool
    let editPermissions: Bool
    let adminRights: Bool
}


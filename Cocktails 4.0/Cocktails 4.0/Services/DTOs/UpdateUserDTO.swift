//
//  UpdateUserDTO.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 07/10/2025.
//

import Foundation

struct UpdateUsernameDTO: Codable {
    let newUsername: String
}

struct UpdatePasswordDTO: Codable {
    let currentPassword: String
    let newPassword: String
    let confirmNewPassword: String
}

struct fetchPublicUserDTO: Codable, Identifiable {
    let id: UUID
    let username: String
    var role: UserRole
}

struct UpdateUserRoleDTO: Codable {
    let id: UUID
    let role: UserRole
}



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

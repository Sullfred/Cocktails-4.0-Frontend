//
//  CreateUserDTO.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/09/2025.
//

struct CreateUserDTO: Codable {
    var username: String
    var password: String
    var confirmPassword: String
}

//
//  LoggedInUser.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/09/2025.
//

import Foundation

struct LoggedInUser: Codable {
    let id: UUID
    var username: String
    var role: UserRole
    var authState: AuthState
}


enum UserRole: String, Codable {
    case guest
    case creator
    case admin
}

enum AuthState: Codable {
    case authenticated, expired, unknown
}

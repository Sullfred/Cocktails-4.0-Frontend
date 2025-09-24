//
//  LoggedInUser.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/09/2025.
//

import Foundation

struct LoggedInUser: Codable {
    let username: String
    let addPermission: Bool
    let editPermissions: Bool
    let adminRights: Bool
}

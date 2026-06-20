//
//  AuthError.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 14/06/2026.
//

import Foundation

enum AuthenticationError: LocalizedError {
    case loginRequired
    
    var errorDescription: String? {
        switch self {
        case .loginRequired:
            return "Login is required."
        }
    }
}

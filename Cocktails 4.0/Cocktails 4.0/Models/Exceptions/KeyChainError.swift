//
//  KeyChainError.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 20/06/2026.
//

import Foundation

enum KeyChainError: LocalizedError {
    case saveTokenError
    case getTokenError
    case deleteTokenError
    
    var errorDescription: String? {
        switch self {
        case .saveTokenError:
            return "Unknown error occured when trying to save token."
        case .getTokenError:
            return "Unknown error occured when trying to get token."
        case .deleteTokenError:
            return "Unknown error occured when trying to delete token."
        }
    }
}

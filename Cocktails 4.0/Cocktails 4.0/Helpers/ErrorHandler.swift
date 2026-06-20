//
//  ErrorHandler.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 27/09/2025.
//

import Foundation

struct ErrorHandler {
    // Converts any application error into a user-friendly message.
    static func userMessage(for error: Error) -> String? {
        switch error {
        case let error as APIError:
            return error.localizedDescription
            
        case let error as PendingActionError:
            return error.localizedDescription
            
        case let error as URLError:
            return error.localizedDescription
            
        case let error as LocalizedError:
            return error.errorDescription
            
        default:
            return "An unexpected error occurred."
        }
    }
    
    // Displays error to the user via ToastManager.
    static func handle(_ error: Error, showToUser: Bool = true) {
        guard showToUser else {
            return
        }
        
        guard let message = userMessage(for: error) else {
            return
        }
        
        ToastManager.shared.show(style: .error, message: message)
    }
}

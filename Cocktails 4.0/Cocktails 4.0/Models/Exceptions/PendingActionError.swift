//
//  PendingActionError.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 09/06/2026.
//

import Foundation

enum PendingActionError: LocalizedError {
    case noLoggedInUser
    case unauthorizedAction
    case invalidLoggedInUserData
    case unsupportedActionType(action: PendingActionType, processor: String)
    case invalidPayload
    case decodingError
    case encodingError
    case imageDecodingError

    var errorDescription: String? {
        switch self {
        case .noLoggedInUser:
            return "No user is currently logged in."
        case .unauthorizedAction:
            return "The pending action does not belong to the current user."
        case .invalidLoggedInUserData:
            return "Failed to load the logged in user."
        case .unsupportedActionType(let action, let processor):
            return "Actions of type \(action) is not supported for processor: \(processor)"
        case .invalidPayload:
            return "Payload is invalid."
        case .decodingError:
            return "Failed to decode payload."
        case .encodingError:
            return "Failed to encode payload."
        case .imageDecodingError:
            return "Failed to decode image payload."
        }
    }
}

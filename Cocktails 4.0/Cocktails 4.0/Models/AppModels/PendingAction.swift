//
//  PendingAction.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 30/09/2025.
//

import Foundation
import SwiftData

enum PendingActionType: String, Codable, CaseIterable {
    case addBarItem
    case deleteBarItem
    case addFavorite
    case deleteFavorite
    case addRemoved
    case deleteRemoved
    case addCocktail
    case editCocktail
    case deleteCocktail
}

extension PendingActionType {
    var stringValue: String { self.rawValue }
}

@Model
final class PendingAction {
    @Attribute(.unique) var id: UUID
    @Attribute var type: PendingActionType
    var payload: Data
    var dateCreated: Date

    init<T: Encodable>(type: PendingActionType, payload: T) {
        self.id = UUID()
        self.type = type
        self.dateCreated = Date()
        let encoder = JSONEncoder()
        do {
            self.payload = try encoder.encode(payload) // raw JSON bytes
        } catch {
            ErrorHandler.handle(ErrorOutput.customError(message: "Failed to encode payload"))
            self.payload = Data()
        }
    }

    func decodePayload<T: Decodable>(as type: T.Type) -> T? {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: payload)
        } catch {
            ErrorHandler.handle(ErrorOutput.customError(message: "Failed to decode payload"))
            return nil
        }
    }
}

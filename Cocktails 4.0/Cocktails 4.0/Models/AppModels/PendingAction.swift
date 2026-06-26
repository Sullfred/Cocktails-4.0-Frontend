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
    case updateCocktail
    case deleteCocktail
}

struct CocktailPayload: Codable {
    let cocktail: CocktailDTO
    let imageAction: ImageAction
    let imageData: Data?
}

enum ImageAction: Codable {
    case unchanged
    case upload
    case update
    case delete
}

extension PendingActionType {
    var stringValue: String { self.rawValue }
}

@Model
final class PendingAction {
    @Attribute(.unique) var id: UUID
    var typeRaw: String
    var type: PendingActionType {
        get { PendingActionType(rawValue: typeRaw)! }
        set { typeRaw = newValue.rawValue }
    }
    var userId: UUID
    var payload: Data
    var dateCreated: Date
    var imageData: Data?
    var retryCount: Int = 0

    init<T: Encodable>(type: PendingActionType, userId: UUID, payload: T) {
        self.id = UUID()
        self.typeRaw = type.rawValue
        self.userId = userId
        self.dateCreated = Date()
        let encoder = JSONEncoder()
        do {
            self.payload = try encoder.encode(payload) // raw JSON bytes
        } catch {
            ErrorHandler.handle(PendingActionError.encodingError)
            self.payload = Data()
        }
    }

    func decodePayload<T: Decodable>(as type: T.Type) -> T? {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: payload)
        } catch {
            ErrorHandler.handle(PendingActionError.decodingError)
            return nil
        }
    }
}

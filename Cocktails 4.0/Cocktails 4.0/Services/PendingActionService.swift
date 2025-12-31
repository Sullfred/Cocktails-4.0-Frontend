//
//  PendingActionService.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 30/09/2025.
//


import Foundation
import SwiftData

@MainActor
final class PendingActionService {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // Add a action to pendingAction
    // PendingActionType is the type of the action and payload is the object
    // Example: Creating a cocktail will create an pending action of type `addCocktail` with the created cocktail being the payload
    func addAction(_ type: PendingActionType, payload: some Encodable, imageData: Data? = nil) throws {
        let action = PendingAction(type: type, payload: payload, imageData: imageData)
        context.insert(action)
        try context.save()
    }

    // Fetch all actions of a certain type
    func fetchActions(ofType type: PendingActionType) throws -> [PendingAction] {
        let allActions = try context.fetch(FetchDescriptor<PendingAction>())
        let filteredActions = allActions.filter { $0.type.rawValue == type.rawValue }

        return filteredActions
    }

    func remove(_ action: PendingAction) throws {
        context.delete(action)
        try context.save()
    }

    // ONLY FOR TESTING PURPOSE DURING DEVELOPMENT - REMOVE LATER
    func fetchAll() throws -> [PendingAction] {
        let descriptor = FetchDescriptor<PendingAction>()
        return try context.fetch(descriptor)
    }
    
    func clearAll() throws {
        let all = try fetchAll()
        for action in all {
            context.delete(action)
        }
        try context.save()
    }
}

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
    func addAction<T: Encodable>(_ type: PendingActionType, payload: T) {
        do {
            let action = PendingAction(type: type, payload: payload)
            context.insert(action)
            try context.save()
        } catch {
            print("Failed to add action: \(error)")
        }
    }

    // Fetch all actions of a certain type
    func fetchActions(ofType type: PendingActionType) -> [PendingAction] {
        do {
            let allActions = try context.fetch(FetchDescriptor<PendingAction>())
            return allActions.filter { $0.type.rawValue == type.rawValue }
        } catch {
            print("Failed to fetch pending actions of type \(type): \(error)")
            return []
        }
    }

    func remove(_ action: PendingAction) {
        context.delete(action)
        do {
            try context.save()
        } catch {
            print("Failed to remove pending action: \(error)")
        }
    }

    // ONLY FOR TESTING PURPOSE DURING DEVELOPMENT - REMOVE LATER
    func fetchAll() -> [PendingAction] {
        let descriptor = FetchDescriptor<PendingAction>()
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch pending actions: \(error)")
            return []
        }
    }
    
    func clearAll() {
        let all = fetchAll()
        for action in all {
            context.delete(action)
        }
        do {
            try context.save()
        } catch {
            print("Failed to clear all pending actions: \(error)")
        }
    }
}

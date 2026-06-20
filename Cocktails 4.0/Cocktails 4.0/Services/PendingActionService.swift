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
    private let sessionStore: UserSessionStore
    
    init(context: ModelContext, sessionStore: UserSessionStore = .shared) {
        self.context = context
        self.sessionStore = sessionStore
    }
    
    // Add a action to pendingAction
    // PendingActionType is the type of the action and payload is the object
    // Example: Creating a cocktail will create an pending action of type `addCocktail` with the created cocktail being the payload
    func addAction(_ type: PendingActionType, payload: some Encodable) throws {
        let action = PendingAction(
            type: type,
            userId: try currentUserId(),
            payload: payload,
        )
        
        context.insert(action)
        try context.save()
    }
    
    // Fetch actions of specified type for the user
    func fetchActions(ofType type: PendingActionType) throws -> [PendingAction] {
        let userId = try currentUserId()
        
        let descriptor = FetchDescriptor<PendingAction>(
            predicate: #Predicate<PendingAction> { action in
                action.userId == userId &&
                action.type == type
            },
            sortBy: [SortDescriptor(\.dateCreated)]
        )
        
        return try context.fetch(descriptor)
    }
    
    // Fecth all actions for the user
    func fetchAll() throws -> [PendingAction] {
        let userId = try currentUserId()
        
        let descriptor = FetchDescriptor<PendingAction>(
            predicate: #Predicate<PendingAction> { action in
                action.userId == userId
            },
            sortBy: [SortDescriptor(\.dateCreated)]
        )
        
        return try context.fetch(descriptor)
    }
    
    // Remove pending action
    func remove(_ action: PendingAction) throws {
        let userId = try currentUserId()
        
        guard action.userId == userId else {
            throw PendingActionError.unauthorizedAction
        }
        
        context.delete(action)
        try context.save()
    }
    
    func clearAll() throws {
        let actions = try fetchAll()
        let userId = try currentUserId()
        
        try context.delete(model: PendingAction.self, where: #Predicate {
            $0.userId == userId
        })
        try context.save()
    }
    
    // Get the current logged in user's userId
    private func currentUserId() throws -> UUID {
        guard let user = try sessionStore.getUser() else {
            throw PendingActionError.noLoggedInUser
        }
        
        return user.id
    }
}

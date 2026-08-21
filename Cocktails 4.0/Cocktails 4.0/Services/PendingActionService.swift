//
//  PendingActionService.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 30/09/2025.
//


import Foundation
import SwiftData

@MainActor
protocol PendingActionServiceProtocol {
    func addAction(_ type: PendingActionType, payload: some Encodable) throws
    func fetchActions(ofType type: PendingActionType) throws -> [PendingAction]
    func fetchAll() throws -> [PendingAction]
    func remove(_ action: PendingAction) throws
    func clearAll() throws
}

@MainActor
class PendingActionService: PendingActionServiceProtocol {
    private let context: ModelContext
    private let sessionStore: UserSessionStore
    
    init(context: ModelContext, sessionStore: UserSessionStore = .shared) {
        self.context = context
        self.sessionStore = sessionStore
    }
    
    func addAction(_ type: PendingActionType, payload: some Encodable) throws {
        let action = PendingAction(
            type: type,
            userId: try currentUserId(),
            payload: payload,
        )
        context.insert(action)
        try context.save()
    }
    
    func fetchActions(ofType type: PendingActionType) throws -> [PendingAction] {
        let userId = try currentUserId()
        let rawType = type.rawValue
        let descriptor = FetchDescriptor<PendingAction>(
            predicate: #Predicate<PendingAction> { action in
                action.userId == userId &&
                action.typeRaw == rawType
            },
            sortBy: [SortDescriptor(\.dateCreated)]
        )
        return try context.fetch(descriptor)
    }
    
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
    
    func remove(_ action: PendingAction) throws {
        let userId = try currentUserId()
        guard action.userId == userId else {
            throw PendingActionError.unauthorizedAction
        }
        context.delete(action)
        try context.save()
    }
    
    func clearAll() throws {
        let userId = try currentUserId()
        try context.delete(model: PendingAction.self, where: #Predicate {
            $0.userId == userId
        })
        try context.save()
    }
    
    private func currentUserId() throws -> UUID {
        guard let user = try sessionStore.getUser() else {
            throw PendingActionError.noLoggedInUser
        }
        return user.id
    }
}


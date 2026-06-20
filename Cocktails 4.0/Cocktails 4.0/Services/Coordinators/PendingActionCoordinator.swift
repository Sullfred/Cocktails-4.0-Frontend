//
//  SyncCoordinator.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 13/06/2026.
//

import Foundation
import SwiftData

@MainActor
protocol PendingActionProcessor {
    func canProcess(_ type: PendingActionType) -> Bool
    func process(_ action: PendingAction) async throws
}

@MainActor
final class PendingActionCoordinator {
    private let pendingActionService: PendingActionService
    private let processors: [any PendingActionProcessor]

    init(
        pendingActionService: PendingActionService,
        processors: [any PendingActionProcessor]
    ) {
        self.pendingActionService = pendingActionService
        self.processors = processors
    }

    func processAllPendingActions() async throws {
        let actions = try pendingActionService.fetchAll()
            .sorted { $0.dateCreated < $1.dateCreated }

        for action in actions {
            do {
                try await process(action)
                try pendingActionService.remove(action)
            } catch {
                ErrorHandler.handle(error)
                continue
            }
        }
    }
    
    func processPendingActionsOfType(type: PendingActionType) async throws {
        let actions = try pendingActionService.fetchActions(ofType: type)
            .sorted { $0.dateCreated < $1.dateCreated }
        
        for action in actions {
            do {
                try await process(action)
                try pendingActionService.remove(action)
            } catch {
                ErrorHandler.handle(error)
                continue
            }
        }
    }

    private func process(_ action: PendingAction) async throws {
        guard let processor = processors.first(where: {
            $0.canProcess(action.type)
        }) else {
            throw PendingActionError.invalidPayload
        }

        try await processor.process(action)
    }
}

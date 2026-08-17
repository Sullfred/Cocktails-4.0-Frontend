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
    func process(_ actions: [PendingAction]) async throws -> [PendingAction]
}

@MainActor
final class PendingActionCoordinator {
    private let pendingActionService: PendingActionService
    private let processors: [any PendingActionProcessor]

    private var isProcessing = false

    init(
        pendingActionService: PendingActionService,
        processors: [any PendingActionProcessor]
    ) {
        self.pendingActionService = pendingActionService
        self.processors = processors
    }

    func processAllPendingActions() async throws {
        guard !isProcessing else {
            return
        }

        isProcessing = true

        defer {
            isProcessing = false
        }

        let actions = try pendingActionService.fetchAll()
            .sorted { $0.dateCreated < $1.dateCreated }

        try await process(actions)
    }

    func processPendingActionsOfType(type: PendingActionType) async throws {
        guard !isProcessing else {
            return
        }

        isProcessing = true

        defer {
            isProcessing = false
        }

        let actions = try pendingActionService.fetchActions(ofType: type)
            .sorted { $0.dateCreated < $1.dateCreated }

        try await process(actions)
    }

    private func process(_ actions: [PendingAction]) async throws {
        for processor in processors {
            let processorActions = actions.filter {
                processor.canProcess($0.type)
            }

            guard !processorActions.isEmpty else {
                continue
            }

            let validActions = processorActions.filter {
                $0.retryCount <= 5
            }

            let expiredActions = processorActions.filter {
                $0.retryCount > 5
            }

            // Give up on actions that have exceeded the retry limit.
            for action in expiredActions {
                try pendingActionService.remove(action)
            }

            guard !validActions.isEmpty else {
                continue
            }

            do {
                let processedActions = try await processor.process(validActions)

                for action in processedActions {
                    try pendingActionService.remove(action)
                }
            } catch {
                for action in validActions {
                    action.retryCount += 1
                }

                ErrorHandler.handle(error)
            }
        }
    }
}

//
//  CocktailsPendingActionProcessor.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 14/06/2026.
//

import Foundation

@MainActor
final class CocktailsPendingActionProcessor: PendingActionProcessor {
    private let supportedTypes: Set<PendingActionType> = [
        .addCocktail,
        .updateCocktail
    ]

    private let cocktailService: CocktailService

    init(cocktailService: CocktailService) {
        self.cocktailService = cocktailService
    }

    func canProcess(_ type: PendingActionType) -> Bool {
        supportedTypes.contains(type)
    }

    func process(_ actions: [PendingAction]) async throws -> [PendingAction] {
        let cocktailActions = actions
            .filter { canProcess($0.type) }
            .sorted { $0.dateCreated < $1.dateCreated }

        guard !cocktailActions.isEmpty else {
            return []
        }

        enum State {
            case create(CocktailPayload)
            case update(CocktailPayload)
        }

        var latestState: [UUID: State] = [:]
        var processedActions: [PendingAction] = []

        for action in cocktailActions {
            guard let payload = action.decodePayload(as: CocktailPayload.self) else {
                throw PendingActionError.decodingError
            }

            let cocktailId = payload.cocktail.id

            switch action.type {
            case .addCocktail:
                latestState[cocktailId] = .create(payload)

            case .updateCocktail:
                if case .create = latestState[cocktailId] {
                    latestState[cocktailId] = .create(payload)
                } else {
                    latestState[cocktailId] = .update(payload)
                }

            default:
                break
            }

            processedActions.append(action)
        }

        for state in latestState.values {
            switch state {
            case .create(let payload):
                try await cocktailService.createCocktail(payload)

            case .update(let payload):
                try await cocktailService.updateCocktail(payload)
            }
        }

        return processedActions
    }
}

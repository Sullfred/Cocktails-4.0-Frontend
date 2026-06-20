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
        .updateCocktail,
    ]
    
    private let cocktailService: CocktailService
    
    init(cocktailService: CocktailService) {
        self.cocktailService = cocktailService
    }
    
    func canProcess(_ type: PendingActionType) -> Bool {
        supportedTypes.contains(type)
    }
    
    func process(_ action: PendingAction) async throws {
        
        guard canProcess(action.type) else {
            throw PendingActionError.unsupportedActionType(action: action.type, processor: "CocktailsPendingActionProcessor")
        }
        
        switch action.type {
        case .addCocktail:
            try await handleCreateCocktail(action)
        case .updateCocktail:
            try await handleUpdateCocktail(action)
        default:
            throw PendingActionError.unsupportedActionType(action: action.type, processor: "CocktailsPendingActionProcessor")
        }
    }
    
    private func handleCreateCocktail(_ action: PendingAction) async throws {
        guard let payload = action.decodePayload(as: CocktailPayload.self) else {
            throw PendingActionError.decodingError
        }
        try await cocktailService.createCocktail(payload)
    }
    
    private func handleUpdateCocktail(_ action: PendingAction) async throws {
        guard let payload = action.decodePayload(as: CocktailPayload.self) else {
            throw PendingActionError.decodingError
        }
        try await cocktailService.updateCocktail(payload)
    }
    
}

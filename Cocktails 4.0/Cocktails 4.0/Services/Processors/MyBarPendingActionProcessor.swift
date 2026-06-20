//
//  MyBarPendingActionProcessor.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 13/06/2026.
//

@MainActor
final class MyBarPendingActionProcessor: PendingActionProcessor {
    private let supportedTypes: Set<PendingActionType> = [
        .addBarItem,
        .deleteBarItem,
        .addFavorite,
        .deleteFavorite,
        .addRemoved,
        .deleteRemoved
    ]

    private let myBarService: MyBarService

    init(myBarService: MyBarService) {
        self.myBarService = myBarService
    }

    func canProcess(_ type: PendingActionType) -> Bool {
        supportedTypes.contains(type)
    }

    func process(_ action: PendingAction) async throws {
        guard canProcess(action.type) else {
            throw PendingActionError.unsupportedActionType(action: action.type, processor: "MyBarPendingActionProcessor")
        }

        switch action.type {
        case .addBarItem:
            try await handleAddBarItem(action)
        case .deleteBarItem:
            try await handleDeleteBarItem(action)
        case .addFavorite:
            try await handleAddFavorite(action)
        case .deleteFavorite:
            try await handleDeleteFavortie(action)
        case .addRemoved:
            try await handleAddRemovedCocktail(action)
        case .deleteRemoved:
            try await handleDeleteRemovedCocktail(action)
        default:
            throw PendingActionError.unsupportedActionType(action: action.type, processor: "MyBarPendingActionProcessor")
        }
    }
    
    private func handleAddBarItem(_ action: PendingAction) async throws {
        guard let payload = action.decodePayload(as: MyBarItemDTO.self) else {
            throw PendingActionError.invalidPayload
        }
        
        try await myBarService.addBarItem(payload)
    }
    
    private func handleDeleteBarItem(_ action: PendingAction) async throws {
        guard let payload = action.decodePayload(as: MyBarItemDTO.self) else {
            throw PendingActionError.invalidPayload
        }
        
        try await myBarService.deleteBarItem(payload)
    }
    
    private func handleAddFavorite(_ action: PendingAction) async throws {
        guard let payload = action.decodePayload(as: String.self) else {
            throw PendingActionError.invalidPayload
        }
        
        try await myBarService.addFavorite(payload)
    }
    
    private func handleDeleteFavortie(_ action: PendingAction) async throws {
        guard let cocktailID = action.decodePayload(as: String.self) else {
            throw PendingActionError.invalidPayload
        }
        
        try await myBarService.deleteFavorite(cocktailID)
    }
    
    private func handleAddRemovedCocktail(_ action: PendingAction) async throws {
        guard let payload = action.decodePayload(as: RemovedCocktailDTO.self) else {
            throw PendingActionError.invalidPayload
        }
        
        try await myBarService.addRemoved(payload)
    }
    
    private func handleDeleteRemovedCocktail(_ action: PendingAction) async throws {
        guard let payload = action.decodePayload(as: RemovedCocktailDTO.self) else {
            throw PendingActionError.invalidPayload
        }
        
        try await myBarService.deleteRemoved(payload)
    }
}

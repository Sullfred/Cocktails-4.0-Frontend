//
//  MyBarPendingActionProcessor.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 13/06/2026.
//

import Foundation

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
    
    func process(_ actions: [PendingAction]) async throws -> [PendingAction] {
        guard actions.allSatisfy({ canProcess($0.type) }) else {
            throw PendingActionError.invalidPayload
        }
        
        var processedActions: [PendingAction] = []
        
        let barItemActions = actions.filter {
            $0.type == .addBarItem || $0.type == .deleteBarItem
        }
        
        if !barItemActions.isEmpty {
            let processed = try await processBarItems(barItemActions)
            processedActions.append(contentsOf: processed)
        }
        
        let favoriteActions = actions.filter {
            $0.type == .addFavorite || $0.type == .deleteFavorite
        }
        
        if !favoriteActions.isEmpty {
            let processed = try await processFavorites(favoriteActions)
            processedActions.append(contentsOf: processed)
        }
        
        let hiddenCocktailActions = actions.filter {
            $0.type == .addRemoved || $0.type == .deleteRemoved
        }
        
        if !hiddenCocktailActions.isEmpty {
            let processed = try await processHiddenCocktails(hiddenCocktailActions)
            processedActions.append(contentsOf: processed)
        }
        
        return processedActions
    }
}

// Bar Items
private extension MyBarPendingActionProcessor {
    func processBarItems(_ actions: [PendingAction]) async throws -> [PendingAction] {
        enum State {
            case add(MyBarItemDTO)
            case delete(UUID)
        }
        
        var states: [UUID: State] = [:]
        
        for action in actions.sorted(by: {
            $0.dateCreated < $1.dateCreated
        }) {
            guard let item = action.decodePayload(as: MyBarItemDTO.self) else {
                throw PendingActionError.invalidPayload
            }
            
            switch action.type {
            case .addBarItem:
                states[item.id] = .add(item)
                
            case .deleteBarItem:
                states[item.id] = .delete(item.id)
                
            default:
                break
            }
        }
        
        let itemsToAdd = states.values.compactMap {
            if case .add(let item) = $0 {
                return item
            }
            
            return nil
        }
        
        let itemIdsToDelete = states.values.compactMap {
            if case .delete(let id) = $0 {
                return id
            }
            
            return nil
        }
        
        if !itemsToAdd.isEmpty {
            try await myBarService.addBarItem(itemsToAdd)
        }
        
        if !itemIdsToDelete.isEmpty {
            try await myBarService.deleteBarItems(itemIdsToDelete)
        }
        
        return actions
    }
}

// Favorites
private extension MyBarPendingActionProcessor {
    func processFavorites(
        _ actions: [PendingAction]
    ) async throws -> [PendingAction] {
        enum State {
            case add(UUID)
            case remove(UUID)
        }
        
        var states: [UUID: State] = [:]
        
        for action in actions.sorted(by: {
            $0.dateCreated < $1.dateCreated
        }) {
            guard let id = action.decodePayload(as: UUID.self) else {
                throw PendingActionError.invalidPayload
            }
            
            switch action.type {
            case .addFavorite:
                states[id] = .add(id)
                
            case .deleteFavorite:
                states[id] = .remove(id)
                
            default:
                break
            }
        }
        
        let idsToAdd = states.values.compactMap {
            if case .add(let id) = $0 {
                return id
            }
            
            return nil
        }
        
        let idsToRemove = states.values.compactMap {
            if case .remove(let id) = $0 {
                return id
            }
            
            return nil
        }
        
        if !idsToAdd.isEmpty {
            try await myBarService.addFavorites(idsToAdd)
        }
        
        if !idsToRemove.isEmpty {
            try await myBarService.deleteFavorites(idsToRemove)
        }
        
        return actions
    }
}

// Hidden Cocktails
private extension MyBarPendingActionProcessor {
    func processHiddenCocktails(
        _ actions: [PendingAction]
    ) async throws -> [PendingAction] {
        enum State {
            case add(HiddenCocktailDTO)
            case delete(UUID)
        }
        
        var states: [UUID: State] = [:]
        
        for action in actions.sorted(by: {
            $0.dateCreated < $1.dateCreated
        }) {
            guard let hiddenCocktail = action.decodePayload(
                as: HiddenCocktailDTO.self
            ) else {
                throw PendingActionError.invalidPayload
            }
            
            let id = hiddenCocktail.id
            
            switch action.type {
            case .addRemoved:
                states[id] = .add(hiddenCocktail)
                
            case .deleteRemoved:
                states[id] = .delete(id)
                
            default:
                break
            }
        }
        
        let hiddenCocktailsToAdd = states.values.compactMap {
            if case .add(let hiddenCocktail) = $0 {
                return hiddenCocktail
            }
            
            return nil
        }
        
        let hiddenCocktailIdsToDelete = states.values.compactMap {
            if case .delete(let id) = $0 {
                return id
            }
            
            return nil
        }
        
        if !hiddenCocktailsToAdd.isEmpty {
            try await myBarService.addHiddenCocktail(hiddenCocktailsToAdd)
        }
        
        if !hiddenCocktailIdsToDelete.isEmpty {
            try await myBarService.deleteRemoved(hiddenCocktailIdsToDelete)
        }
        
        return actions
    }
}

//
//  CocktailsViewModel.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 27/09/2025.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
final class CocktailViewModel: ObservableObject {
    @Published var isLoading = false

    private let dependencies: AppDependencies
    
    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }
    
    func sync() async {
        isLoading = true
        defer {
            isLoading = false
        }
        
        do {
            // Perform fetch
            let fetchedCocktails = try await dependencies.cocktailService.fetchCocktails()
            
            // Update local state
            let (addedCocktails, deletedCocktails) = try dependencies.syncCoordinator.syncCocktails(fetchedCocktails: fetchedCocktails)
            
            // display toast messages to inform user
            if !addedCocktails.isEmpty {
                if addedCocktails.count > 5 {
                    ToastManager.shared.show(style: .info, message: "\(addedCocktails.count) cocktails added.")
                } else {
                    ToastManager.shared.show(style: .info, message: "Cocktails deleted: \(addedCocktails.joined(separator: ", "))")
                }
            }
            
            if !deletedCocktails.isEmpty {
                ToastManager.shared.show(style: .info, message: "Cocktails deleted: \(deletedCocktails.joined(separator: ", "))")
            }
            
        } catch {
            ErrorHandler.handle(error)
        }
    }
    
    func fetchLocalCocktails() -> [Cocktail] {
        let cocktailDescriptor = FetchDescriptor<Cocktail>()
        
        do {
            let localCocktails = try dependencies.contexCoordinator.fetch(cocktailDescriptor)
            return localCocktails
        }
        catch {
            ErrorHandler.handle(error)
        }
        
        return []
    }
    
    func addNewCocktail(_ cocktail: Cocktail) async {
        // Update local state
        do {
            try dependencies.contexCoordinator.insert(cocktail)
        } catch {
            ErrorHandler.handle(error)
        }
        
        // Add item to pending queue
        let payload = CocktailPayload(
            cocktail: CocktailDTO(from: cocktail),
            imageAction: cocktail.image == nil ? .unchanged : .upload,
            imageData: cocktail.image
        )
        
        queueAddCocktail(payload)
        do {
            try await dependencies.pendingActionCoordinator.processPendingActionsOfType(type: .addCocktail)
        } catch {
            ErrorHandler.handle(error)
        }
    }
    
    func updateCocktail(_ draft: CocktailDraft, cocktail: Cocktail) async {
        // create image variables
        let old = cocktail.image
        let new = draft.image
        
        // Update local state
        do {
            try dependencies.contexCoordinator.performBatch {
                draft.apply(to: cocktail)
            }
        } catch {
            ErrorHandler.handle(error)
        }
        
        
        
        // Add item to pending queue
        var imageAction: ImageAction
        
        if old == nil && new != nil {
            imageAction = .upload
        } else if old != nil && new == nil {
            imageAction = .delete
        } else if old != nil && new != nil && old != new {
            imageAction = .update
        } else {
            imageAction = .unchanged
        }
        
        let payload = CocktailPayload(
            cocktail: CocktailDTO(from: cocktail),
            imageAction: imageAction,
            imageData: new
        )
        
        queueUpdateCocktail(payload)
        
        do {
            try await dependencies.pendingActionCoordinator.processPendingActionsOfType(type: .updateCocktail)
        } catch {
            ErrorHandler.handle(error)
        }
    }
    
    func refresh() async {
        if await dependencies.cocktailService.checkServerConnection() {
            await sync()
        }
    }
    
    private func queueAddCocktail(_ item: CocktailPayload) {
        do {
            try dependencies.pendingActionService.addAction(.addCocktail, payload: item)
        } catch {
            ErrorHandler.handle(error)
        }
    }
    
    private func queueUpdateCocktail(_ item: CocktailPayload) {
        do {
            try dependencies.pendingActionService.addAction(.updateCocktail, payload: item)
        } catch {
            ErrorHandler.handle(error)
        }
    }
}

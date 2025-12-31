//
//  CocktailsViewModel.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 27/09/2025.
//

import Foundation
import SwiftUI
import SwiftData
import KeychainSwift

@MainActor
final class CocktailViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let context: ModelContext
    private let service: CocktailService
    private let pendingActionService: PendingActionService
    
    init(context: ModelContext) {
        self.context = context
        self.service = CocktailService(context: context)
        self.pendingActionService = PendingActionService(context: context)
    }
    
    func sync() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let fetchedCocktails = try await service.fetchCocktails()
            
            // Fetch local cocktails
            let localCocktails = try context.fetch(FetchDescriptor<Cocktail>())
            
            // Create dictionaries for easy lookup
            let fetchedDict = Dictionary(uniqueKeysWithValues: fetchedCocktails.map { ($0.id, $0) })
            let localDict = Dictionary(uniqueKeysWithValues: localCocktails.map { ($0.id, $0) })
            
            // Identify cocktails to remove (local but not in fetched)
            let deletedCocktails = localCocktails.filter { fetchedDict[$0.id] == nil }
            for cocktail in deletedCocktails {
                context.delete(cocktail)
            }
            
            // Identify cocktails to update (existing IDs)
            let toUpdate = localCocktails.filter { fetchedDict[$0.id] != nil }
            for cocktail in toUpdate {
                if let updatedCocktail = fetchedDict[cocktail.id] {
                    cocktail.name = updatedCocktail.name
                    cocktail.creator = updatedCocktail.creator
                    cocktail.ingredients = updatedCocktail.ingredients
                    cocktail.image = updatedCocktail.image
                    cocktail.comment = updatedCocktail.comment
                }
            }
            
            // Identify cocktails to add (in fetched but not local)
            let addedCocktails = fetchedCocktails.filter { localDict[$0.id] == nil }
            for cocktail in addedCocktails {
                context.insert(cocktail)
            }
            
            try context.save()
            
            // display toast messages to inform user
            if !addedCocktails.isEmpty {
                if localCocktails.isEmpty {
                    ToastManager.shared.show(style: .info, message: "\(addedCocktails.count) cocktails added.")
                } else {
                    let addedNames = addedCocktails.map{$0.name.capitalized}
                    ToastManager.shared.show(style: .info, message: "Cocktails deleted: \(addedNames.joined(separator: ", "))")
                }
            }
            
            if !deletedCocktails.isEmpty {
                let removedNames = deletedCocktails.map{$0.name.capitalized}
                
                ToastManager.shared.show(style: .info, message: "Cocktails deleted: \(removedNames.joined(separator: ", "))")
            }
            
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
        }
    }
    
    func addNewCocktail(_ cocktail: Cocktail) async {
        // Update local state
        do {
            context.insert(cocktail)
            try context.save()
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
        }
        
        // Add item to pending queue
        do {
            let dto = CocktailDTO(from: cocktail)
            if let imageData = cocktail.image {
                try pendingActionService.addAction(.addCocktail, payload: dto, imageData: imageData)
            } else {
                try pendingActionService.addAction(.addCocktail, payload: dto)
            }
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
        }
        
        // Attempt to sync with database
        do {
            // Get userToken
            let keychain = KeychainSwift()
            guard let token = keychain.get("userToken")
            else {
                return
            }
            
            try await service.addNewCocktail(userToken: token)
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
        }
    }
    
    func updateCocktail(_ draft: CocktailDraft, cocktail: Cocktail) async {
        // create image variables
        let old = cocktail.image
        let new = draft.image
        
        // Update local state
        do {
            draft.apply(to: cocktail)
            try context.save()
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
        }
        
        // Add item to pending queue
        do {
            let dto = CocktailDTO(from: cocktail)
            
            if (old == nil && new != nil) || (old != nil && new != nil && old != new) {
                // Add/update image
                try pendingActionService.addAction(.updateCocktail, payload: dto, imageData: new)
            } else if (old != nil && new == nil) {
                // Delete image
                try pendingActionService.addAction(.deleteCocktailImage, payload: dto.id)
            } else {
                // Image unchanged
                try pendingActionService.addAction(.updateCocktail, payload: dto)
            }
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
        }
        
        // Attempt to sync with database
        do {
            // Get userToken
            let keychain = KeychainSwift()
            guard let token = keychain.get("userToken")
            else {
                return
            }
            
            try await service.updateCocktail(userToken: token)
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
        }
    }
    
    func syncAll() async {
        do {
            // Get userToken
            let keychain = KeychainSwift()
            guard let token = keychain.get("userToken")
            else {
                return
            }
            
            try await service.addNewCocktail(userToken: token)
            try await service.updateCocktail(userToken: token)
            
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
        }
    }
    
    func refresh() async {
        if await service.checkServerConnection() {
            await sync()
        }
    }
}

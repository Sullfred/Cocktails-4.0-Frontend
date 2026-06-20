//
//  SyncCoordinator.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 20/06/2026.
//

import Foundation
import SwiftData

@MainActor
final class SyncCoordinator {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func syncCocktails(fetchedCocktails: [Cocktail]) throws -> (addedCocktails: [String], deletedCocktails: [String]) {
        do {
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
            
            // handle name list
            let addedCocktailsName = addedCocktails.map{$0.name.capitalized}
            let deletedCocktailsName = deletedCocktails.map{$0.name.capitalized}
            
            return(addedCocktailsName, deletedCocktailsName)
        } catch {
            
        }
        
        return ([],[])
    }
    
}

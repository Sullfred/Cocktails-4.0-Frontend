//
//  CocktailListViewModel.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 02/08/2026.
//

import SwiftUI
import Foundation

@MainActor
final class CocktailListViewModel: ObservableObject {
    private let searchManager: SearchManager
    
    @Published private(set) var visibleCocktails: [Cocktail] = []

    var cocktails: [Cocktail] = []
    var personalBar: MyBar = MyBar()
    var criteria = CocktailFilterCriteria() {
        didSet { recompute() }
    }
    
    init(searchManager: SearchManager = .shared) {
        self.searchManager = searchManager
    }


    func update(cocktails: [Cocktail], personalBar: MyBar) {
        self.cocktails = cocktails
        self.personalBar = personalBar
        recompute()
    }

    private func recompute() {
        var filtered = cocktails

        if criteria.showFavoritesOnly {
            let favorites = Set(personalBar.favoriteCocktails)

            filtered = filtered.filter {
                favorites.contains($0.id.uuidString)
            }
        }

        let removedCocktailIds = Set(
            personalBar.removedCocktails.map { $0.cocktailId }
        )

        filtered = filtered.filter {
            !removedCocktailIds.contains($0.id.uuidString)
        }

        if criteria.showCraftableOnly {
            let availableIngredients = Set(
                personalBar.myBarItems.map { $0.name }
            )

            filtered = filtered.filter {
                searchManager.canCraft($0, using: availableIngredients)
            }
        }

        filtered = filtered.filter { cocktail in
            searchManager.matches(
                cocktail: cocktail,
                searchTerms: criteria.searchTerms
            )
        }

        if let category = criteria.selectedCategory {
            filtered = filtered.filter {
                $0.cocktailCategory == category
            }
        }

        if let baseSpirit = criteria.baseSpirit {
            filtered = filtered.filter { cocktail in
                cocktail.ingredients.contains {
                    $0.tag == baseSpirit
                }
            }
        }

        visibleCocktails = filtered
    }
}


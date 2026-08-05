//
//  IngredientGroupManager.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 31/07/2026.
//

import Foundation

final class SearchManager {
    static let shared = SearchManager()
    
    var ingredientGroups: [String: [String]]
    
    init(ingredientGroups: [String: [String]] = loadIngredientGroups()) {
        self.ingredientGroups = ingredientGroups
    }
    
    func canonicalName(for ingredient: String) -> String {
        let lowercased = ingredient.lowercased()
        for (canonical, variants) in ingredientGroups {
            if canonical == lowercased || variants.contains(lowercased) {
                return canonical
            }
        }
        return lowercased
    }

    func matchesIngredient(_ ingredient: String, barItems: Set<String>) -> Bool {
        let canonicalIngredientName = canonicalName(for: ingredient)

        let canonicalBarItems = Set(
            barItems.map { canonicalName(for: $0) }
        )

        if canonicalBarItems.contains(canonicalIngredientName) {
            return true
        }

        for barItem in canonicalBarItems {
            if barItem.contains(canonicalIngredientName)
                || canonicalIngredientName.contains(barItem) {
                return true
            }
        }

        return false
    }

    func canCraft(_ cocktail: Cocktail, using barItems: Set<String>) -> Bool {
        cocktail.ingredients.allSatisfy { ingredient in
            matchesIngredient(ingredient.name, barItems: barItems)
        }
    }
    
    private func matchesSearchTerm(_ searchTerm: String, ingredient: String) -> Bool {
        let normalizedSearch = searchTerm.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        let canonicalSearch = canonicalName(for: normalizedSearch)
        let canonicalIngredient = canonicalName(for: ingredient.lowercased())

        return ingredient.lowercased().contains(normalizedSearch)
            || canonicalIngredient == canonicalSearch
            || canonicalIngredient.contains(canonicalSearch)
    }

    func matches(cocktail: Cocktail, searchTerm: String) -> Bool {
        let normalizedTerm = searchTerm.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        if (cocktail.name.lowercased().contains(normalizedTerm)) {
            return true
        }

        if (cocktail.creator.lowercased().contains(normalizedTerm)) {
            return true
        }

        if (cocktail.ingredients.contains(where: {
            matchesSearchTerm(normalizedTerm, ingredient: $0.name)
        })) {
            return true
        }

        return false
    }

    func matches(cocktail: Cocktail, searchTerms: [String]) -> Bool {
        let normalizedTerms = searchTerms.map {
                $0.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .filter {
                !$0.isEmpty
            }

        guard !normalizedTerms.isEmpty else {
            return true
        }

        return normalizedTerms.allSatisfy {
            matches(cocktail: cocktail,searchTerm: $0)
        }
    }


    static func loadIngredientGroups() -> [String: [String]] {
        guard let url = Bundle.main.url(forResource: "IngredientGroups", withExtension: "json") else {
            return [:]
        }
        do {
            let data = try Data(contentsOf: url)
            let groups = try JSONDecoder().decode([String: [String]].self, from: data)
            return groups
        } catch {
            return [:]
        }
    }
}

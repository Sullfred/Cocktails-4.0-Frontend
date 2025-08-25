//
//  view_cocktailsListSorted.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 18/08/2025.
//

import SwiftUI
import SwiftData

struct view_cocktailsListSorted: View {
    @Environment(\.modelContext) private var modelContext
    
    let selectedCategory: CocktailCategory?
    var baseSpirit: IngredientTag?
    var showCraftableOnly: Bool
    let searchTerms: [String]
    var showFavoritesOnly: Bool
    
    @Query(sort: [
        SortDescriptor(\Cocktail.name),
        SortDescriptor(\Cocktail.creator)
    ]) var allCocktails: [Cocktail]
    @Query private var bars: [MyBar]
    
    private var filteredCocktails: [Cocktail] {
        let barItems = Set(bars.first?.myBarItems.map { $0.name.lowercased() } ?? [])
        let favorites = Set(bars.first?.favoriteCocktails ?? [])
        
        return allCocktails.filter { cocktail in
            (selectedCategory == nil || cocktail.cocktailCategory == selectedCategory)
            &&
            (baseSpirit == nil || cocktail.ingredients.contains { ingredient in
                ingredient.tag == baseSpirit
            })
            &&
            (!showCraftableOnly || cocktail.ingredients.allSatisfy { ingredient in
                        barItems.contains(ingredient.name.lowercased())
            })
            &&
            (!showFavoritesOnly || favorites.contains(cocktail.id.uuidString))
            &&
            (searchTerms.isEmpty || searchTerms.allSatisfy { term in
                cocktail.name.localizedStandardContains(term) ||
                cocktail.ingredients.contains { ingredient in
                    ingredient.name.localizedStandardContains(term)
                }
            })
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredCocktails) { cocktail in
                NavigationLink(destination: view_cocktailDetails(cocktail: cocktail)) {
                    VStack(alignment: .leading) {
                        view_cocktailListItem(cocktail: cocktail)
                    }
                }
            }
            .onDelete(perform: deleteCocktail)
            .listRowBackground(Color.clear)
        }
    }
    
    init(sortOrder: [SortDescriptor<Cocktail>], searchText: String, showFavoritesOnly: Bool, showCraftableOnly: Bool, selectedCategory: CocktailCategory?, baseSpirit: IngredientTag?) {
        self.selectedCategory = selectedCategory
        self.baseSpirit = baseSpirit
        self.showCraftableOnly = showCraftableOnly
        self.showFavoritesOnly = showFavoritesOnly
        
        self.searchTerms = searchText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
        
        _allCocktails = Query(filter: #Predicate<Cocktail> { cocktail in
            searchText.isEmpty ||
            searchText.contains(",") ||
            cocktail.name.localizedStandardContains(searchText) ||
            cocktail.ingredients.contains { ingredient in
                ingredient.name.localizedStandardContains(searchText)
            }
        }, sort: sortOrder)
    }
    
    func deleteCocktail(_ indexSet: IndexSet) {
        for index in indexSet {
            let cocktail = allCocktails[index]
            modelContext.delete(cocktail)
        }
    }
}

#Preview {
    view_cocktailsListSorted(sortOrder: [
        SortDescriptor(\Cocktail.name),
        SortDescriptor(\Cocktail.creator)
    ], searchText: "", showFavoritesOnly: false, showCraftableOnly: false, selectedCategory: nil, baseSpirit: nil)
}

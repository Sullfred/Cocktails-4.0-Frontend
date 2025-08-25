//
//  view_cocktailsListSorted.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 18/08/2025.
//

import SwiftUI
import SwiftData

struct old_view_cocktailsListSorted: View {
    @Environment(\.modelContext) private var modelContext
    
    let selectedCategory: CocktailCategory?
    var showCraftableOnly: Bool
    
    @Query(sort: [
        SortDescriptor(\Cocktail.name),
        SortDescriptor(\Cocktail.creator)
    ]) var allCocktails: [Cocktail]
    @Query private var bars: [MyBar]
    
    private var filteredCocktails: [Cocktail] {
        let barItems = Set(bars.first?.myBarItems.map { $0.name.lowercased() } ?? [])
        
        return allCocktails.filter { cocktail in
            (selectedCategory == nil || cocktail.cocktailCategory == selectedCategory)
            &&
            (!showCraftableOnly || cocktail.ingredients.allSatisfy { ingredient in
                        barItems.contains(ingredient.name.lowercased())
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
    
    init(sortOrder: [SortDescriptor<Cocktail>], searchText: String, showFavoritesOnly: Bool, showCraftableOnly: Bool, selectedCategory: CocktailCategory?) {
        self.selectedCategory = selectedCategory
        self.showCraftableOnly = showCraftableOnly
        
        _allCocktails = Query(filter: #Predicate<Cocktail> {
            cocktail in
            (
                searchText.isEmpty ||
                cocktail.name.localizedStandardContains(searchText) ||
                cocktail.ingredients.contains { ingredient in
                    ingredient.name.localizedStandardContains(searchText)
                }
            )
            //&&
            //(!showFavoritesOnly || cocktail.favorite)
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
    old_view_cocktailsListSorted(sortOrder: [
        SortDescriptor(\Cocktail.name),
        SortDescriptor(\Cocktail.creator)
    ], searchText: "", showFavoritesOnly: false, showCraftableOnly: false, selectedCategory: nil)
}

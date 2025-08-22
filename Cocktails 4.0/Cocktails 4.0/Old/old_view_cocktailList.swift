//
//  view_cocktailList.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/07/2025.
//

import Foundation
import SwiftUI
import SwiftData

struct old_view_cocktailList: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: [SortDescriptor(\Cocktail.name, order: .reverse), SortDescriptor(\Cocktail.creator)]) var cocktails: [Cocktail]
    
    
    var body: some View {
        List {
            ForEach(cocktails) { cocktail in
                NavigationLink(value: cocktail) {
                    VStack(alignment: .leading) {
                        view_cocktailListItem(cocktail: cocktail)
                    }
                }
            }
            .onDelete(perform: deleteCocktail)
            .listRowBackground(Color.clear)
        }
        
    }
    
    // Seach by either name or ingredient
    init(sort: SortDescriptor<Cocktail>, searchString: String, showFavoritesOnly: Bool, selectedCategory: CocktailCategory?) {
        _cocktails = Query(filter: #Predicate<Cocktail> { cocktail in
            (
                searchString.isEmpty ||
                cocktail.name.localizedStandardContains(searchString) ||
                cocktail.ingredients.contains { ingredient in
                    ingredient.name.localizedStandardContains(searchString)
                }
            )
            &&
            (!showFavoritesOnly || cocktail.favorite)
        }, sort: [sort])
    }
    
    func deleteCocktail(_ indexSet: IndexSet) {
        for index in indexSet {
            let cocktail = cocktails[index]
            modelContext.delete(cocktail)
        }
    }
    
}

#Preview {
    old_view_cocktailList(sort: SortDescriptor(\Cocktail.name), searchString: "", showFavoritesOnly: false, selectedCategory: nil )
}

//
//  CocktailFilterCriteria.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 02/08/2026.
//


struct CocktailFilterCriteria: Equatable {
    var searchTerms: [String] = []
    var showFavoritesOnly = false
    var showCraftableOnly = false
    var selectedCategory: CocktailCategory?
    var baseSpirit: IngredientTag?
}

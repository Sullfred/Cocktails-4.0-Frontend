//
//  Favorite.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 12/07/2026.
//

func isFavorite(cocktail: Cocktail, myBar: MyBar) -> Bool {
    myBar.favoriteCocktails.contains(cocktail.id.uuidString)
}

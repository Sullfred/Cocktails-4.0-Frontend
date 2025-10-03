//
//  Helpers.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 22/07/2025.
//


import Foundation
import SwiftData
import SwiftUI

func convertUnit (ingredient: Ingredient, targetUnit: UnitVolume) -> Double? {
    guard let fromUnit = ingredient.unit.ingredientUnit else {
        return nil // unsupported conversion
    }
    
    return Measurement(value: ingredient.volume, unit: fromUnit).converted(to: targetUnit).value
}


func isFavorite(cocktail: Cocktail, myBar: MyBar) -> Bool {
    myBar.favoriteCocktails.contains(cocktail.id.uuidString)
}

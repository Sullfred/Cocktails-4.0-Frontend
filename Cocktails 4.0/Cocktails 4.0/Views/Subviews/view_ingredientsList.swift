//
//  view_ingredientsList.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/07/2025.
//

import Foundation
import SwiftUI
import SwiftData

struct view_ingredientsList: View {
    var ingredient: Ingredient
     
    var measurementUnit : UnitVolume
    var servings : Double
     
    var body: some View {
        HStack {
            Text("-")
            Text(ingredient.unit == .ml || ingredient.unit == .cl || ingredient.unit == .oz ? (convertUnit(ingredient: ingredient, targetUnit: measurementUnit) ?? 0) * servings : ingredient.volume * servings, format: .number.rounded(rule: .toNearestOrEven, increment: 0.01))
                .frame(width: 55.0,  alignment: .trailing)
            Text(ingredient.unit == .ml || ingredient.unit == .cl || ingredient.unit == .oz ? measurementUnit.symbol : ingredient.unit.rawValue)
                .frame(width: 40.0, alignment: .leading)
            Text(ingredient.name.capitalized)
        }
         
     }
 }

#Preview {
    let testCocktail = Cocktail(
        name: "Whiskey sour",
        creator: "Daniel Kleist",
        style: .shaken,
        ingredients: [Ingredient(volume: 60, unit: .ml, name: "bourbon"),
            Ingredient(volume: 1, unit: .oz, name: "lemon juice"),
            Ingredient(volume: 15, unit: .ml, name: "simple syrup"),
            Ingredient(volume: 15, unit: .ml, name: "egg white"),
            Ingredient(volume: 3, unit: .dash, name: "angostura bitters")
        ],
        comment: "angostura bitters can be left out",
        favorite: true,
        image: nil,
        cocktailCategory: .sour
    )
    
    view_ingredientsList(ingredient: testCocktail.ingredients[0], measurementUnit: .milliliters, servings: 1)
}

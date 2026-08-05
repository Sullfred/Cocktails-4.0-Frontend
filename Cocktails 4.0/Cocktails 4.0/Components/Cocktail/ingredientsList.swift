//
//  view_ingredientsList.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/07/2025.
//

import Foundation
import SwiftUI
import SwiftData

struct ingredientsList: View {
    var ingredient: Ingredient
    
    var displayedAmount: Double
    var displayedUnit: String
    var onEditRequest: () -> Void
    
    var body: some View {
        HStack {
            Text("-")
            
            Button(action: onEditRequest) {
                HStack(spacing: 2) {
                    Text(
                        displayedAmount,
                        format: .number.rounded(rule: .toNearestOrEven, increment: 0.01)
                    )
                    .padding(.trailing, 10)

                    Text(displayedUnit)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.gray.opacity(0.15))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

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
        image: nil,
        cocktailCategory: .sour
    )
    

    
    ingredientsList(ingredient: testCocktail.ingredients[0], displayedAmount: 60, displayedUnit: "ml", onEditRequest: {})
}

//
//  view_cocktailListItem.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/07/2025.
//

import SwiftUI

struct view_cocktailListItem: View {
    var cocktail: Cocktail
    
    let columns = [GridItem(.adaptive(minimum: 70, maximum: 80))]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Cocktail name
            Text(cocktail.name.capitalized)
                .font(.headline)
            
            // Optional creator
            if !cocktail.creator.isEmpty {
                Text("By \(cocktail.creator.capitalized)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Ingredients (list of names)
            Text(
                cocktail.ingredients
                    .sorted(by: { $0.orderIndex < $1.orderIndex })
                    .map { $0.name.capitalized }
                    .joined(separator: ", ")
            )
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        
    }
}

#Preview {
    let imageData = UIImage(resource: .cocktailPreview).pngData()
    
    let testCocktail = Cocktail(
        name: "Whiskey sour",
        creator: "Daniel Kleist",
        style: .shaken,
        ingredients: [
            Ingredient(volume: 60, unit: .ml, name: "bourbon", orderIndex: 0),
            Ingredient(volume: 1, unit: .oz, name: "lemon juice", orderIndex: 1),
            Ingredient(volume: 15, unit: .ml, name: "simple syrup", orderIndex: 2),
            Ingredient(volume: 15, unit: .ml, name: "egg white", orderIndex: 3),
            Ingredient(volume: 3, unit: .dash, name: "angostura bitters", orderIndex: 4)
        ],
        comment: "angostura bitters can be left out",
        image: imageData,
        cocktailCategory: .sour
    )
    
    view_cocktailListItem(cocktail: testCocktail)
}


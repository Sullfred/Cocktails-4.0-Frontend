//
//  CocktailCard.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 12/07/2026.
//

import SwiftUI

struct CocktailCard: View {
    let cocktail: Cocktail
    
    var body: some View {
        NavigationLink(destination: CocktailDetails(cocktail: cocktail)) {
            VStack(spacing: 15) {
                VStack(spacing: 4) {
                    Text(cocktail.name.capitalized)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(cocktail.cocktailCategory.localizedName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text(formatIngredients(cocktail.ingredients))
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
            }
            .padding(.top, 5)
        }
        .padding(.vertical, 30)
        .padding(.horizontal)
        .frame(width: 350, height: 200)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.backgroundSecondary)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    private func formatIngredients(_ ingredients: [Ingredient]) -> String {
        let names = ingredients.map { $0.name.capitalized }
        return names.joined(separator: " • ")
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
        comment: "Angostura bitters can be left out",
        image: imageData,
        cocktailCategory: .sour
    )
    
    CocktailCard(cocktail: testCocktail)
}

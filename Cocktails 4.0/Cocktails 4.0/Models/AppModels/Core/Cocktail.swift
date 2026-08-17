//
//  Cocktail.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 22/07/2025.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Cocktail {
    #Index<Cocktail>([\.name], [\.creator])
    
    // Base cocktail
    var id: UUID = UUID()
    var name: String
    var creator: String
    var style: Style
    @Relationship(deleteRule: .cascade) var ingredients: [Ingredient]
    var comment: String
    var cocktailCategory: CocktailCategory
    
    // Cocktail image
    @Attribute(.externalStorage) var image : Data?
    var imageURL: String?
    
    // Init model
    init(name: String = "", creator: String = "", style: Style = .shaken, ingredients: [Ingredient] = [], comment: String = "", image: Data?, imageURL: String? = nil, cocktailCategory: CocktailCategory) {
        self.name = name
        self.creator = creator
        self.style = style
        self.ingredients = ingredients
        self.comment = comment
        self.image = image
        self.imageURL = imageURL
        self.cocktailCategory = cocktailCategory
    }
    
}

// Cocktail styles
enum Style: String, Codable, CaseIterable {
    case shaken = "Shaken", stirred = "Stirred", blended = "Blended", flash = "Flash blended", whip = "Whip shaken", mixed = "Mixed"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

enum CocktailCategory: String, Codable, CaseIterable {
    case sour = "Sour", highball = "Highballs and Fizzes", spiritForward = "Spirit-Forward", mocktail = "Mocktails", tiki = "Tiki Cocktails", duos = "Duos", champagne = "Champagne Cocktails", juleps = "Juleps and Smashes", dessert = "Dessert Cocktails", other = "Other"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

struct CocktailDraft {
    var name: String
    var creator: String
    var style: Style
    var ingredients: [Ingredient]
    var comment: String
    var cocktailCategory: CocktailCategory
    var image: Data?
    
    init(from cocktail: Cocktail) {
        self.name = cocktail.name.capitalized
        self.creator = cocktail.creator.capitalized
        self.style = cocktail.style
        // Deep copy of ingredients as Ingredient is reference due to @Model
        self.ingredients = cocktail.ingredients.map { ingredient in
            Ingredient(
                volume: ingredient.volume,
                unit: ingredient.unit,
                name: ingredient.name,
                orderIndex: ingredient.orderIndex
            )
        }.sorted(by: {$0.orderIndex < $1.orderIndex})
        
        self.comment = cocktail.comment
        self.cocktailCategory = cocktail.cocktailCategory
        self.image = cocktail.image
    }
    
    func apply(to cocktail: Cocktail) {
        cocktail.name = name.lowercased()
        cocktail.creator = creator.lowercased()
        cocktail.style = style
        cocktail.ingredients = ingredients.map { ingredient in
            ingredient.name = ingredient.name.lowercased()
            ingredient.assignTagBasedOnName()
            return ingredient
        }
        cocktail.comment = comment
        cocktail.cocktailCategory = cocktailCategory
        cocktail.image = image
    }
}


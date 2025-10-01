//
//  CocktailDTO.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/09/2025.
//

import Foundation

struct CocktailDTO: Codable, Identifiable {
    var id: UUID
    var name: String
    var creator: String
    var style: String
    var comment: String
    var cocktailCategory: String
    var imageURL: String?
    var ingredients: [IngredientDTO]
}

// MARK: - Conversion Extensions
extension CocktailDTO {
    init(from cocktail: Cocktail) {
        self.id = cocktail.id
        self.name = cocktail.name
        self.creator = cocktail.creator
        self.style = cocktail.style.rawValue
        self.comment = cocktail.comment
        self.cocktailCategory = cocktail.cocktailCategory.rawValue
        self.imageURL = cocktail.imageURL // Placeholder for image URL encoding
        self.ingredients = cocktail.ingredients.map { IngredientDTO(from: $0) }
    }
}

extension Cocktail {
    convenience init(from dto: CocktailDTO) {
        self.init(
            name: dto.name,
            creator: dto.creator,
            style: Style(rawValue: dto.style) ?? .shaken,
            ingredients: dto.ingredients.map { Ingredient(from: $0) },
            comment: dto.comment,
            image: nil, // no Data from server
            imageURL: dto.imageURL,
            cocktailCategory: CocktailCategory(rawValue: dto.cocktailCategory) ?? .other
        )
        self.id = dto.id
    }
}

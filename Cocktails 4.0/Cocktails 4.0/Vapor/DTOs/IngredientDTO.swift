//
//  IngredientDTO.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/09/2025.
//

import Foundation

struct IngredientDTO: Codable, Identifiable {
    var id: UUID
    var volume: Double
    var unit: String
    var name: String
    var tag: String?
    var orderIndex: Int
}

// MARK: - Conversion Extensions
extension IngredientDTO {
    init(from ingredient: Ingredient) {
        self.id = ingredient.id
        self.volume = ingredient.volume
        self.unit = ingredient.unit.rawValue
        self.name = ingredient.name
        self.tag = ingredient.tag?.rawValue
        self.orderIndex = ingredient.orderIndex
    }
}

extension Ingredient {
    convenience init(from dto: IngredientDTO) {
        self.init(
            volume: dto.volume,
            unit: Iunit(rawValue: dto.unit) ?? .ml,
            name: dto.name, orderIndex: dto.orderIndex
        )
        self.id = dto.id
        self.tag = IngredientTag(rawValue: dto.tag ?? "")
    }
}

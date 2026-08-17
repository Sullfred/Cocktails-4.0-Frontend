//
//  Ingredient.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 22/07/2025.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Ingredient {
    #Index<Ingredient>([\.name])
    
    var id: UUID = UUID()
    var volume: Double
    var unit: Iunit
    var name: String
    var tag: IngredientTag? = nil
    var orderIndex: Int
    
    @Relationship(inverse: \Cocktail.ingredients)
        var cocktail: Cocktail?
    
    init(volume: Double = 30, unit: Iunit = .ml, name: String = "", orderIndex: Int = 0) {
        self.volume = volume
        self.unit = unit
        self.name = name
        self.orderIndex = orderIndex
    }
}

// Measurement units
enum Iunit: String, Codable, CaseIterable {
    case ml = "mL", cl = "cL", oz = "oz", tsp = "tsp", dash = "dash", drop = "drop", leaves = "leaves", piece = "piece"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

extension Iunit {
    var ingredientUnit: UnitVolume? {
        switch self {
        case .ml:
            return .milliliters
        case .cl:
            return .centiliters
        case .oz:
            return .fluidOunces
        default:
            return nil // dash and drop are not supported in UnitVolume and tsp is not needed for conversion
        }
    }
}

enum IngredientTag: String, Codable, CaseIterable, Identifiable {
    case whiskey, rum, gin, brandy, vodka, tequila

    var id: String { rawValue.capitalized }
}

extension Ingredient {
    static let tagKeywords: [IngredientTag: [String]] = {
        guard
            let url = Bundle.main.url(forResource: "IngredientTagKeywords", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let rawDict = try? JSONDecoder().decode([String: [String]].self, from: data)
        else {
            return [:]
        }
        var result: [IngredientTag: [String]] = [:]
        for (key, keywords) in rawDict {
            if let tag = IngredientTag(rawValue: key) {
                result[tag] = keywords
            }
        }
        return result
    }()

    func assignTagBasedOnName() {
        let lower = name.lowercased()
        for (tag, keywords) in Ingredient.tagKeywords {
            if keywords.contains(where: { lower.contains($0) }) {
                self.tag = tag
                return
            }
        }
        self.tag = nil
    }
}

//
//  IngredientItem.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 25/07/2025.
//


//
//  Liquid.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 25/07/2025.
//

import Foundation
import SwiftData

struct IngredientItem {
    var name: String
    var tag: IngredientTag? = nil
    
    
    init(name: String) {
        self.name = name
    }
}


enum _IngredientTag: String, Codable, CaseIterable, Identifiable {
    case whiskey, vermouth, rum, gin, tequila, vodka, brandy, noTag

    var id: String { rawValue.capitalized }
}

extension IngredientItem {
    mutating func assignTagBasedOnName() {
        let lowercasedName = name.lowercased()

        // Dictionary mapping tags to keywords that should map to them
        let tagKeywords: [IngredientTag: [String]] = [
            .whiskey: ["whiskey", "bourbon", "rye", "scotch", "irish", "whisky"],
            .rum: ["rum", "cachaça", "cachaca", "aguardiente"],
            .gin: ["gin", "london dry", "contemporary", "new western", "new american", "plymouth", "old tom", "genever"],
            //.vermouth: ["vermouth"],
            .tequila: ["tequila"],
            .vodka: ["vodka"],
            .brandy: ["brandy", "cognac", "armagnac", "calvados", "pisco", "grappa", "metaxa"],
        ]

        for (tag, keywords) in tagKeywords {
            for keyword in keywords {
                if lowercasedName.contains(keyword) {
                    self.tag = tag
                    return
                }
            }
        }

        // Default if no match found
        self.tag = nil
    }
}

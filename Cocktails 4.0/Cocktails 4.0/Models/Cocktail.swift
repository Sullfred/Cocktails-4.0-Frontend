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
    // Base cocktail
    var id: UUID = UUID()
    var name: String
    var creator: String
    var style: Style
    @Relationship(deleteRule: .cascade) var ingredients: [Ingredient]
    var comment: String
    var cocktailCategory: CocktailCategory
    var favorite: Bool
    
    // Cocktail image
    @Attribute(.externalStorage)
    var image : Data?
    
    // Init model
    init(name: String = "", creator: String = "", style: Style = .shaken, ingredients: [Ingredient] = [], comment: String = "", favorite: Bool = false, image: Data?, cocktailCategory: CocktailCategory) {
        self.name = name
        self.creator = creator
        self.style = style
        self.ingredients = ingredients
        self.comment = comment
        self.favorite = favorite
        self.image = image
        self.cocktailCategory = cocktailCategory
    }
    
}

// Cocktail styles
enum Style: String, Codable, CaseIterable {
    case shaken = "Shaken", stirred = "Stirred", blended = "Blended", flash = "Flash blended", whip = "Whip shaken"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

enum CocktailCategory: String, Codable, CaseIterable {
    case sour = "Sour", highball = "Highball", spiritForward = "Spirit-Forward", mocktail = "Mocktail", tiki = "Tiki Cocktails", duosAndTrios = "Duos and Trios", champagne = "Champagne Cocktails", juleps = "Juleps and Smashes", cobbler = "Cobblers", other = "Other"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}



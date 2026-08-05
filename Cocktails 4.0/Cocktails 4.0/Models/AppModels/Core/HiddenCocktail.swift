//
//  HiddenCocktail.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 24/06/2026.
//

import Foundation

struct HiddenCocktail: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var cocktailId: String
    var name: String
    var creator: String
    var date: Date
    
    init(cocktailId: String, name: String, creator: String, date: Date = Date.now) {
        self.cocktailId = cocktailId
        self.name = name
        self.creator = creator
        self.date = date
    }
}

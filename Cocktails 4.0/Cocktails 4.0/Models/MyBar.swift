//
//  myBar.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 22/07/2025.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class MyBar {
    var myBarItems: [MyBarItem]
    var favoriteCocktails: [String]
    var deletedCocktails: [DeletedCocktail]
    
    init(myBarItems: [MyBarItem] = [], favoriteCocktails: [String] = [], deletedCocktails: [DeletedCocktail] = []) {
        self.myBarItems = myBarItems
        self.favoriteCocktails = favoriteCocktails
        self.deletedCocktails = deletedCocktails
    }
}

struct DeletedCocktail: Codable, Hashable, Identifiable {
    var id: String
    var name: String
    var creator: String
    var date: Date = Date.now
    
    init(id: String, name: String, creator: String) {
        self.id = id
        self.name = name
        self.creator = creator
    }
}

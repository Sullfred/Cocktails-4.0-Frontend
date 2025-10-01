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
    var id: UUID = UUID()
    var userId: UUID?
    var myBarItems: [MyBarItem]
    var favoriteCocktails: [String]
    var removedCocktails: [RemovedCocktail]
    
    init(userId: UUID? = nil, myBarItems: [MyBarItem] = [], favoriteCocktails: [String] = [], deletedCocktails: [RemovedCocktail] = []) {
        self.userId = userId
        self.myBarItems = myBarItems
        self.favoriteCocktails = favoriteCocktails
        self.removedCocktails = deletedCocktails
    }
}

struct RemovedCocktail: Codable, Hashable, Identifiable {
    var id: String
    var name: String
    var creator: String
    var date: Date
    
    init(id: String, name: String, creator: String, date: Date = Date.now) {
        self.id = id
        self.name = name
        self.creator = creator
        self.date = date
    }
}

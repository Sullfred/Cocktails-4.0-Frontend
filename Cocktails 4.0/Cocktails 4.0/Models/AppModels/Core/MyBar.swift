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
    var removedCocktails: [HiddenCocktail]
    
    init(userId: UUID? = nil, myBarItems: [MyBarItem] = [], favoriteCocktails: [String] = [], deletedCocktails: [HiddenCocktail] = []) {
        self.userId = userId
        self.myBarItems = myBarItems
        self.favoriteCocktails = favoriteCocktails
        self.removedCocktails = deletedCocktails
    }
}



//Default state
extension MyBar {
    static var empty: MyBar {
        MyBar(
            myBarItems: [],
            favoriteCocktails: [],
            deletedCocktails: []
        )
    }
}

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
    
    init(myBarItems: [MyBarItem] = [], favoriteCocktails: [String] = []) {
        self.myBarItems = myBarItems
        self.favoriteCocktails = favoriteCocktails
    }
}

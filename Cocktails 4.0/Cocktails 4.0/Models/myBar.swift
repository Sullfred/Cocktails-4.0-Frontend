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
class myBar {
    var myBarItems: [MyBarItem]
    
    init(myBarItems: [MyBarItem] = []) {
        self.myBarItems = myBarItems
        
    }
}

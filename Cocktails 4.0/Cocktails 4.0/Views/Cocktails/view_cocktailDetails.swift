//
//  view_cocktailDetails.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/07/2025.
//

import Foundation
import SwiftUI
import SwiftData

struct view_cocktailDetails: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    var cocktail: Cocktail
    
    @State private var isEditing: Bool = false
    
    var body: some View {
        view_cocktailDetailsInfo(cocktail: cocktail)
            .toolbar {
                if (loginViewModel.currentUser?.editPermissions ?? false) == true {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isEditing = true
                        }) {
                            Text("Edit")
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $isEditing) {
                view_cocktailDetailsEdit(cocktail: cocktail)
            }
    }
        
}

#Preview {
    let imageData = UIImage(resource: .cocktailPreview).pngData()
    
    let testCocktail = Cocktail(
        name: "Whiskey sour",
        creator: "Daniel Kleist",
        style: .shaken,
        ingredients: [
            Ingredient(volume: 60, unit: .ml, name: "bourbon", orderIndex: 0),
            Ingredient(volume: 1, unit: .oz, name: "lemon juice", orderIndex: 1),
            Ingredient(volume: 15, unit: .ml, name: "simple syrup", orderIndex: 2),
            Ingredient(volume: 15, unit: .ml, name: "egg white", orderIndex: 3),
            Ingredient(volume: 3, unit: .dash, name: "angostura bitters", orderIndex: 4)
        ],
        comment: "Angostura bitters can be left out",
        image: imageData,
        cocktailCategory: .sour
    )
    
    view_cocktailDetails(cocktail: testCocktail)
        .environmentObject({
            let vm = LoginViewModel()
            vm.currentUser = LoggedInUser(
                id: UUID(),
                username: "Daniel Vang Kleist",
                addPermission: false,
                editPermissions: false,
                adminRights: false
            )
            return vm
        }())
}

//
//  view_cocktailDetails.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/07/2025.
//

import Foundation
import SwiftUI
import SwiftData

struct CocktailDetails: View {
    @EnvironmentObject var cocktailViewModel: CocktailViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myBarViewModel: MyBarViewModel
    
    var cocktail: Cocktail
    
    @State private var isEditing: Bool = false
    
    var body: some View {
        CocktailDetailsInfo(cocktail: cocktail)
            .toolbar {
                if (userViewModel.canCreateCocktails) {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            editCocktail()
                        }) {
                            Text("cocktails_edit")
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $isEditing) {
                CocktailDetailsEdit(cocktail: cocktail)
            }
    }
    
    func editCocktail() {
        if userViewModel.currentUser != nil {
            toggleIfAuthenticated(isAuthenticated: userViewModel.isLoggedIn, toggleVar: &isEditing)
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
    
    // Create an in-memory model container for previews
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MyBar.self, configurations: config)
    let context = container.mainContext
    
    let dependencies = AppDependencies(context: context)
    let myBarVM = MyBarViewModel(dependencies: dependencies)
    
    CocktailDetails(cocktail: testCocktail)
        .environmentObject({
            let vm = UserViewModel(dependencies: dependencies)
            vm.currentUser = LoggedInUser(
                id: UUID(),
                username: "Daniel Vang Kleist",
                role: .admin,
                authState: .authenticated
            )
            return vm
        }())
        .environmentObject(myBarVM)
}

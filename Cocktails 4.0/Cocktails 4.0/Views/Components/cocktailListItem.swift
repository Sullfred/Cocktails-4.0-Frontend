//
//  view_cocktailListItem.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/07/2025.
//

import SwiftUI
import SwiftData

struct cocktailListItem: View {
    @EnvironmentObject var myBarViewModel: MyBarViewModel
    
    var cocktail: Cocktail
    
    let columns = [GridItem(.adaptive(minimum: 70, maximum: 80))]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                // Cocktail name
                Text(cocktail.name.capitalized)
                    .font(.headline)
                
                Spacer()
                
                
                if isFavorite(cocktail: cocktail, myBar: myBarViewModel.personalBar) {
                    Label("", systemImage: "heart.fill")
                }
            }
            // Optional creator
            if !cocktail.creator.isEmpty {
                Text("By \(cocktail.creator.capitalized)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Ingredients (list of names)
            Text(
                cocktail.ingredients
                    .sorted(by: { $0.orderIndex < $1.orderIndex })
                    .map { $0.name.capitalized }
                    .joined(separator: ", ")
            )
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .frame(minHeight: 68)
        
    }
}

#Preview {
    let imageData = UIImage(resource: .cocktailPreview).pngData()
    
    let testCocktail = Cocktail(
        name: "Whiskey sour",
        creator: "",
        style: .shaken,
        ingredients: [
            Ingredient(volume: 60, unit: .ml, name: "bourbon", orderIndex: 0),
            Ingredient(volume: 1, unit: .oz, name: "lemon juice", orderIndex: 1),
            Ingredient(volume: 15, unit: .ml, name: "simple syrup", orderIndex: 2),
            Ingredient(volume: 15, unit: .ml, name: "egg white", orderIndex: 3),
            Ingredient(volume: 3, unit: .dash, name: "angostura bitters", orderIndex: 4)
        ],
        comment: "angostura bitters can be left out",
        image: imageData,
        cocktailCategory: .sour
    )
    
    // Create an in-memory model container for previews
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MyBar.self, configurations: config)
    let context = container.mainContext
    
    let myBarVM = MyBarViewModel(context: context)
    
    cocktailListItem(cocktail: testCocktail)
        .environmentObject(myBarVM)
}


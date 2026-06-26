//
//  view_cocktailDetailsInfo.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 19/08/2025.
//

import SwiftUI
import SwiftData

struct view_cocktailDetailsInfo: View {
    @EnvironmentObject var myBarViewModel: MyBarViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    var cocktail : Cocktail
    
    @State private var selectedMeasurement: UnitVolume = .milliliters
    let measurementUnits: [UnitVolume] = [.milliliters, .centiliters, .fluidOunces]
    
    @State private var selectedServing: Double = 1
    let servings: [Double] = [1, 2, 3, 4]
    
    var body: some View {
        ZStack{
            ScrollView {
                VStack{
                    if cocktail.image != nil {
                        if let photoData = cocktail.image, let uiImage = UIImage(data: photoData) {
                            imageContainer(image: uiImage, size: 280)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text(cocktail.name.capitalized)
                            .font(.title)
                            .bold()
                        
                        HStack(alignment: .bottom){
                            
                            if (cocktail.creator.count > 0) {
                                Text("By " + cocktail.creator.capitalized)
                                    .font(.caption)
                                    .fontWeight(.light)
                                    .opacity(0.8)
                                    .multilineTextAlignment(.center)
                            }
                            Spacer()
                            Text(cocktail.style.localizedName).font(.subheadline).opacity(0.8)
                        }
                        
                        Divider()
                        Text("Ingredients:").font(.title2).padding(.bottom, 2)
                        
                        HStack{
                            VStack{
                                Text("Servings").font(.subheadline).opacity(0.9)
                                
                                Picker("Servings", selection: $selectedServing) {
                                    ForEach(servings, id: \.self) { serving in
                                        Text(serving, format: .number.precision(.fractionLength(0)))
                                    }
                                }.pickerStyle(.segmented)
                            }
                            
                            VStack{
                                Text("Unit of measurement").font(.subheadline).opacity(0.9)
                                
                                Picker("Unit of measurement", selection: $selectedMeasurement) {
                                    ForEach(measurementUnits, id: \.self) { measurementUnit in
                                        Text(measurementUnit.symbol)
                                    }
                                }.pickerStyle(.segmented)
                            }
                        }.padding(.bottom, 10)
                        
                        VStack(alignment: .leading) {
                            ForEach (cocktail.ingredients.sorted(by: { $0.orderIndex < $1.orderIndex })){ ingredient in
                                ingredientsList(ingredient: ingredient, measurementUnit: selectedMeasurement, servings: selectedServing)
                            }
                        }
                        
                        
                        Spacer().frame(height: 15)
                        
                        if (!cocktail.comment.isEmpty) {
                            Text("Comment:").font(.title3).padding(.bottom, 1)
                            Text(cocktail.comment)
                                .padding(.bottom, 15)
                        }
                    }
                    .padding(.horizontal, 20.0)
                }
            }
        }
        .containerRelativeFrame([.horizontal, .vertical])
        .background(.colorSet2)
        .toolbar{
            if (userViewModel.isLoggedIn) {
                ToolbarItem {
                    Button(action: {
                        toggleFavorite(cocktailId: cocktail.id.uuidString)
                    }) {
                        Label(
                            "Toggle favorite",
                            systemImage: isFavorite(cocktail: cocktail, myBar: myBarViewModel.personalBar) ? "heart.fill" : "heart"
                        )
                    }
                    .contentTransition(.symbolEffect(.replace))
                }
            }
        }
    }
    
    func toggleFavorite(cocktailId: String) {
        Task {
            if myBarViewModel.personalBar.favoriteCocktails.contains(cocktailId) {
                await myBarViewModel.deleteFavorite(cocktailId)
            } else {
                await myBarViewModel.addFavorite(cocktailId)
            }
        }
    }
}

#Preview {
    // Create an in-memory model container for previews
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MyBar.self, configurations: config)
    let context = container.mainContext
    
    let dependencies = AppDependencies(context: context)
    let myBarVM = MyBarViewModel(dependencies: dependencies)
    
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
    
    view_cocktailDetailsInfo(cocktail: testCocktail)
        .environmentObject(myBarVM)
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
}

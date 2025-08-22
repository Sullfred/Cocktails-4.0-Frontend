//
//  view_cocktailDetailsEdit.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 19/08/2025.
//

import SwiftUI
import SwiftData
import PhotosUI

struct view_cocktailDetailsEdit: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var cocktail: Cocktail
    @State private var draft: CocktailDraft
    
    @State var selectedPhoto : PhotosPickerItem?
    
    @State private var newIngredientItemName: String = ""
    @State private var newIngredientVolume: Double = 0
    @State private var newIngredientUnit: Iunit = .ml
    
    init(cocktail: Cocktail) {
        self.cocktail = cocktail
        _draft = State(initialValue: CocktailDraft(from: cocktail))
    }
    
    var body: some View {
        NavigationStack {
            Form{
            //Photo
            Section{
                if let photoData = draft.image, let uiImage = UIImage(data: photoData) {
                    view_imageContainer(image: uiImage, size: 200)
                }
                
                if draft.image == nil {
                    PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                        Label("Add Image", systemImage: "photo")
                            .foregroundStyle(Color.colorSet4)
                    }
                }
                
                if draft.image != nil {
                    PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                        Label("Change Image", systemImage: "photo")
                            .foregroundStyle(Color.colorSet4)
                    }
                    
                    Button(role: .destructive) {
                        withAnimation {
                            selectedPhoto = nil
                            draft.image = nil
                        }
                    } label: {
                        Label("Remove Image", systemImage: "xmark")
                            .foregroundStyle(Color.colorSet5)
                    }
                }
            }
            
            // Info
            Section{
                HStack{
                    Text("Name: ")
                    TextField("Name", text: $draft.name)
                }
                HStack{
                    Text("Created by: ")
                    TextField("Created by", text: $draft.creator)
                }
                Picker("Cocktail style", selection: $draft.style) {
                    ForEach(Style.allCases, id: \.self) { style in
                        Text(style.localizedName)
                    }
                }.tint(.black)
                Picker("Cocktail Category", selection: $draft.cocktailCategory) {
                    ForEach(CocktailCategory.allCases, id: \.self) { category in
                        Text(category.localizedName)
                    }
                }.tint(.black)
            }header: {
                Text("Info").font(.headline)
            }.foregroundStyle(.black)
            
            // Ingredients
            Section{
                ForEach($draft.ingredients) { $ingredient in
                    HStack {
                        TextField("", value: $ingredient.volume, format: .number)
                            .frame(width: 40)
                            .textFieldStyle(.plain)
                            .foregroundStyle(.black)
                        
                        Divider()
                        
                        Picker("", selection: $ingredient.unit) {
                            ForEach(Iunit.allCases, id: \.self) { unit in
                                Text(unit.localizedName)
                            }
                        }
                        .labelsHidden()
                        .tint(.black)
                        
                        Divider()
                        
                        TextField("Ingredient", text: $ingredient.name)
                            .foregroundStyle(.black)
                        
                        Spacer()
                        
                        Divider()
                        
                        Button(action: {
                            withAnimation {
                                draft.ingredients.removeAll { $0.id == ingredient.id }
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.colorSet5)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                HStack{
                    TextField("", value: $newIngredientVolume, format: .number)
                        .frame(width: 40.0)
                        .textFieldStyle(.plain)
                        .foregroundStyle(.black)
                    
                    Divider()
                    
                    Picker("", selection: $newIngredientUnit) {
                        ForEach(Iunit.allCases, id: \.self) {
                            unit in Text(unit.localizedName)
                        }
                    }
                    .tint(.black)
                    .labelsHidden()
                    
                    Divider()
                    
                    TextField("New ingredient", text: $newIngredientItemName).foregroundStyle(.black)
                    
                    Divider()
                    
                    Button(action: {
                        withAnimation {
                            let newOrderIndex = draft.ingredients.count
                            let ingredient = Ingredient(volume: newIngredientVolume, unit: newIngredientUnit, name: newIngredientItemName, orderIndex: newOrderIndex)
                            ingredient.assignTagBasedOnName()
                            draft.ingredients.append(ingredient)
                            newIngredientVolume = 0
                            newIngredientItemName = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.colorSet4)
                    }
                    .disabled(newIngredientItemName.isEmpty)
                    .buttonStyle(PlainButtonStyle())
                }
                 
            }header: {
                Text("Ingredients").font(.headline).foregroundStyle(.black)
            }
            
            // Comment
            Section{
                TextField("Comment", text: $draft.comment, axis: .vertical).lineLimit(3)
            }header: {
                Text("Comment").font(.headline)
            }.foregroundStyle(.black)
            
            }
            .tint(.blue)
            .background(Color("ColorSet2"))
            .scrollContentBackground(.hidden)
            .task(id: selectedPhoto) {
                if let photoData = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                    draft.image = photoData
                }
            }
            .navigationTitle("Edit Cocktail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        draft.apply(to: cocktail)
                        do {
                            try modelContext.save()
                        } catch {
                            // handle error if needed
                        }
                        dismiss()
                    }
                    .disabled(draft.name.isEmpty)
                }
            }
        }
    }
}

struct CocktailDraft {
    var name: String
    var creator: String
    var style: Style
    var ingredients: [Ingredient]
    var comment: String
    var cocktailCategory: CocktailCategory
    var favorite: Bool
    var image: Data?
    
    init(from cocktail: Cocktail) {
        self.name = cocktail.name.capitalized
        self.creator = cocktail.creator.capitalized
        self.style = cocktail.style
        // Deep copy of ingredients
        self.ingredients = cocktail.ingredients.map { ingredient in
            Ingredient(
                volume: ingredient.volume,
                unit: ingredient.unit,
                name: ingredient.name,
                orderIndex: ingredient.orderIndex
            )
        }.sorted(by: {$0.orderIndex < $1.orderIndex})
        
        self.comment = cocktail.comment
        self.cocktailCategory = cocktail.cocktailCategory
        self.favorite = cocktail.favorite
        self.image = cocktail.image
    }
    
    func apply(to cocktail: Cocktail) {
        cocktail.name = name.lowercased()
        cocktail.creator = creator.lowercased()
        cocktail.style = style
        cocktail.ingredients = ingredients.map { ingredient in
            ingredient.name = ingredient.name.lowercased()
            ingredient.assignTagBasedOnName()
            return ingredient
        }
        cocktail.comment = comment
        cocktail.cocktailCategory = cocktailCategory
        cocktail.favorite = favorite
        cocktail.image = image
    }
}

#Preview {
    let imageData = UIImage(resource: .cocktailPreview).pngData()
    
    let testCocktail = Cocktail(
        name: "Whiskey sour",
        creator: "daniel kleist",
        style: .shaken,
        ingredients: [
            Ingredient(volume: 60, unit: .ml, name: "bourbon", orderIndex: 0),
            Ingredient(volume: 1, unit: .oz, name: "lemon juice", orderIndex: 1),
            Ingredient(volume: 15, unit: .ml, name: "simple syrup", orderIndex: 2),
            Ingredient(volume: 15, unit: .ml, name: "egg white", orderIndex: 3),
            Ingredient(volume: 3, unit: .dash, name: "angostura bitters", orderIndex: 4)
        ],
        comment: "Angostura bitters can be left out",
        favorite: true,
        image: imageData,
        cocktailCategory: .sour
    )
    
    view_cocktailDetailsEdit(cocktail: testCocktail)
}

//
//  view_cocktailDetailsEdit.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 19/08/2025.
//

import SwiftUI
import SwiftData
import PhotosUI

struct CocktailDetailsEdit: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var cocktailViewModel: CocktailViewModel
    
    var cocktail: Cocktail
    @State private var draft: CocktailDraft
    
    @State var selectedPhoto : PhotosPickerItem?
    
    @State private var newIngredientItemName: String = ""
    @State private var newIngredientVolume: Double = 0
    @State private var newIngredientUnit: Iunit = .ml
    
    @State private var showError = false
    @State private var errorMessage = ""
    
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
                        imageContainer(image: uiImage, size: 200)
                    }
                    
                    if draft.image == nil {
                        PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                            Label("image_add", systemImage: "photo")
                                .foregroundStyle(Color.textTitle)
                        }
                    }
                    
                    if draft.image != nil {
                        PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                            Label("image_change", systemImage: "photo")
                                .foregroundStyle(Color.textTitle)
                        }
                        
                        Button(role: .destructive) {
                            withAnimation {
                                selectedPhoto = nil
                                draft.image = nil
                            }
                        } label: {
                            Label("image_remove", systemImage: "xmark")
                                .foregroundStyle(Color.destructive)
                        }
                    }
                }
                .listRowBackground(Color.backgroundSecondary)
                 
                // Info
                Section{
                    HStack{
                        Text("info_name_title")
                            .foregroundStyle(Color.textTitle)
                        TextField("info_name", text: $draft.name)
                            .foregroundStyle(Color.textPrimary)
                    }
                    HStack{
                        Text("info_created_by_title")
                            .foregroundStyle(Color.textTitle)
                        TextField("info_created_by", text: $draft.creator)
                            .foregroundStyle(Color.textPrimary)
                    }
                    Picker("info_cocktail_style", selection: $draft.style) {
                        ForEach(Style.allCases, id: \.self) { style in
                            Text(style.localizedName)
                        }
                    }.tint(Color.textPrimary)
                    Picker("info_cocktail_category", selection: $draft.cocktailCategory) {
                        ForEach(CocktailCategory.allCases, id: \.self) { category in
                            Text(category.localizedName)
                        }
                    }.tint(Color.textPrimary)
                }header: {
                    Text("info")
                        .font(.headline)
                        .foregroundStyle(Color.textTitle)
                }
                .listRowBackground(Color.backgroundSecondary)
                
                // Ingredients
                Section{
                    ForEach($draft.ingredients) { $ingredient in
                        HStack {
                            TextField("", value: $ingredient.volume, format: .number)
                                .frame(width: 40)
                                .textFieldStyle(.plain)
                                .foregroundStyle(Color.textPrimary)
                            
                            Divider()
                            
                            Picker("", selection: $ingredient.unit) {
                                ForEach(Iunit.allCases, id: \.self) { unit in
                                    Text(unit.localizedName)
                                }
                            }
                            .labelsHidden()
                            .tint(Color.textPrimary)
                            
                            Divider()
                            
                            TextField("info_ingredient", text: $ingredient.name)
                                .foregroundStyle(Color.textPrimary)
                            
                            Spacer()
                            
                            Divider()
                            
                            Button(action: {
                                withAnimation {
                                    draft.ingredients.removeAll { $0.id == ingredient.id }
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(Color.destructive)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    HStack{
                        TextField("", value: $newIngredientVolume, format: .number)
                            .frame(width: 40.0)
                            .textFieldStyle(.plain)
                            .foregroundStyle(Color.textPrimary)
                        
                        Divider()
                        
                        Picker("", selection: $newIngredientUnit) {
                            ForEach(Iunit.allCases, id: \.self) {
                                unit in Text(unit.localizedName)
                            }
                        }
                        .tint(Color.textPrimary)
                        .labelsHidden()
                        
                        Divider()
                        
                        TextField("info_new_ingredient", text: $newIngredientItemName)
                            .foregroundStyle(Color.textPrimary)
                        
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
                                .foregroundStyle(Color.textPrimary)
                        }
                        .disabled(newIngredientItemName.isEmpty)
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                }header: {
                    Text("info_ingredients")
                        .font(.headline)
                        .foregroundStyle(Color.textTitle)
                }
                .listRowBackground(Color.backgroundSecondary)
                
                // Comment
                Section{
                    TextField("info_comment", text: $draft.comment, axis: .vertical).lineLimit(3)
                        .foregroundStyle(Color.textPrimary)
                }header: {
                    Text("info_comment")
                        .font(.headline)
                        .foregroundStyle(Color.textTitle)
                }
                .listRowBackground(Color.backgroundSecondary)
            }
            .tint(.blue)
            .background(Color.background)
            .scrollContentBackground(.hidden)
            .task(id: selectedPhoto) {
                guard let photoData = try? await selectedPhoto?.loadTransferable(type: Data.self) else {
                    return
                }
                draft.image = prepareImageForUpload(photoData)
            }
            .navigationTitle("cocktails_edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") {
                        Task {
                            await cocktailViewModel.updateCocktail(draft, cocktail: cocktail)
                        }
                        dismiss()
                    }
                    .disabled(draft.name.isEmpty)
                }
            }
        }
        .alert("save_error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
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
        image: imageData,
        cocktailCategory: .sour
    )
    
    CocktailDetailsEdit(cocktail: testCocktail)
}

//
//  view_newCocktail.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/07/2025.
//

import Foundation
import SwiftData
import SwiftUI
import PhotosUI

struct NewCocktail: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var cocktailViewModel: CocktailViewModel
    
    @State var selectedPhoto : PhotosPickerItem?
    
    @State private var newCocktailImage: Data?
    @State private var newCocktailName: String = ""
    @State private var newCocktailStyle: Style = .shaken
    @State private var newCocktailCategory: CocktailCategory = .other
    @State private var newCocktailIngredients: [Ingredient] = []
    @State private var newIngredientItemName: String = ""
    @State private var newIngredientVolume: Double = 0
    @State private var newIngredientUnit: Iunit = .ml
    @State private var newCocktailCreator: String = ""
    @State private var newCocktailComment: String = ""
    
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        Form{
            //Photo
            Section{
                if let photoData = newCocktailImage, let uiImage = UIImage(data: photoData) {
                    imageContainer(image: uiImage, size: 200)
                }
                
                if newCocktailImage == nil {
                    PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                        Label("image_add", systemImage: "photo")
                            .foregroundStyle(Color.textTitle)
                    }
                }
                
                if newCocktailImage != nil {
                    PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                        Label("image_change", systemImage: "photo")
                            .foregroundStyle(Color.textTitle)
                    }
                    
                    Button(role: .destructive) {
                        withAnimation {
                            selectedPhoto = nil
                            newCocktailImage = nil
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
                    TextField("info_name", text: $newCocktailName)
                        .foregroundStyle(Color.textPrimary)
                }
                HStack{
                    Text("info_created_by_title")
                        .foregroundStyle(Color.textTitle)
                    TextField("info_created_by", text: $newCocktailCreator)
                        .foregroundStyle(Color.textPrimary)
                }
                Picker("info_cocktail_style", selection: $newCocktailStyle) {
                    ForEach(Style.allCases, id: \.self) { style in
                        Text(style.localizedName)
                    }
                }.tint(Color.textPrimary)
                Picker("info_cocktail_category", selection: $newCocktailCategory) {
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
                ForEach($newCocktailIngredients) { $ingredient in
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
                                newCocktailIngredients.removeAll { $0.id == ingredient.id }
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
                            let newOrderIndex = newCocktailIngredients.count
                            let ingredient = Ingredient(volume: newIngredientVolume, unit: newIngredientUnit, name: newIngredientItemName, orderIndex: newOrderIndex)
                            
                            newCocktailIngredients.append(ingredient)
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
                TextField("info_comment", text: $newCocktailComment, axis: .vertical).lineLimit(3)
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
            let processed = await Task.detached(priority: .userInitiated) { () -> Data? in
                return prepareImageForUpload(photoData)
            }.value
            await MainActor.run {
                newCocktailImage = processed
            }
        }
        .safeAreaInset(edge: .bottom) { //Save and Cancel button
            HStack{
                Button("cancel") {
                    cancel()
                }
                .padding(8)
                .frame(width: 100, height: 30)
                .background(.white.opacity(0.9),
                            in: Capsule())
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.destructive, lineWidth: 3)
                )
                .foregroundStyle(Color.destructive)
                
                Spacer().frame(width: 80)
                
                Button("save") {
                    save()
                }
                .disabled(newCocktailName.isEmpty || newCocktailIngredients.isEmpty)
                .padding(8)
                .frame(width: 100, height: 30)
                .background(.white.opacity(0.9),
                            in: Capsule())
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.textPrimary, lineWidth: 3)
                )
                .foregroundStyle(Color.textPrimary)
            }
            .padding(.bottom, 10)
        }
        .alert("save_error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    func save() {
        do {
            newCocktailIngredients = newCocktailIngredients.map { ingredient in
                ingredient.name = ingredient.name.lowercased()
                ingredient.assignTagBasedOnName()
                return ingredient
            }
            
            let newCocktail = Cocktail(name: newCocktailName.lowercased(), creator: newCocktailCreator.lowercased(), style: newCocktailStyle, ingredients: newCocktailIngredients, comment: newCocktailComment, image: newCocktailImage ?? nil, cocktailCategory: newCocktailCategory)
            
            
            Task {
                await cocktailViewModel.addNewCocktail(newCocktail)
            }
            
            dismiss()
        }
    }
    
    func cancel() {
        dismiss()
    }
}

#Preview {
    NewCocktail()
}

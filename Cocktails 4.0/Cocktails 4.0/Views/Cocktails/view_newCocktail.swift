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

struct view_newCocktail: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @StateObject private var service = CocktailService.shared
    
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
                        Label("Add Image", systemImage: "photo")
                            .foregroundStyle(Color.colorSet4)
                    }
                }
                
                if newCocktailImage != nil {
                    PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                        Label("Change Image", systemImage: "photo")
                            .foregroundStyle(Color.colorSet4)
                    }
                    
                    Button(role: .destructive) {
                        withAnimation {
                            selectedPhoto = nil
                            newCocktailImage = nil
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
                    TextField("Name", text: $newCocktailName)
                }
                HStack{
                    Text("Created by: ")
                    TextField("Created by", text: $newCocktailCreator)
                }
                Picker("Cocktail style", selection: $newCocktailStyle) {
                    ForEach(Style.allCases, id: \.self) { style in
                        Text(style.localizedName)
                    }
                }.tint(.black)
                Picker("Cocktail Category", selection: $newCocktailCategory) {
                    ForEach(CocktailCategory.allCases, id: \.self) { category in
                        Text(category.localizedName)
                    }
                }.tint(.black)
            }header: {
                Text("Info").font(.headline)
            }.foregroundStyle(.black)
            
            // Ingredients
            Section{
                ForEach($newCocktailIngredients) { $ingredient in
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
                                newCocktailIngredients.removeAll { $0.id == ingredient.id }
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
                            let newOrderIndex = newCocktailIngredients.count
                            let ingredient = Ingredient(volume: newIngredientVolume, unit: newIngredientUnit, name: newIngredientItemName, orderIndex: newOrderIndex)
                            
                            newCocktailIngredients.append(ingredient)
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
                TextField("Comment", text: $newCocktailComment, axis: .vertical).lineLimit(3)
            }header: {
                Text("Comment").font(.headline)
            }.foregroundStyle(.black)
            
        }
        .tint(.blue)
        .background(Color("ColorSet2"))
        .scrollContentBackground(.hidden)
        .task(id: selectedPhoto) {
            if let photoData = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                newCocktailImage = photoData
            }
        }
        .safeAreaInset(edge: .bottom) { //Save and Cancel button
            HStack{
                Button("Cancel") {
                    cancel()
                }
                .padding(8)
                .frame(width: 100, height: 30)
                .background(.white.opacity(0.9),
                            in: Capsule())
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.colorSet5, lineWidth: 3)
                )
                .tint(Color.colorSet5)
                
                Spacer().frame(width: 80)
                
                Button("Save") {
                    save()
                }
                .disabled(newCocktailName.isEmpty || newCocktailIngredients.isEmpty)
                .padding(8)
                .frame(width: 100, height: 30)
                .background(.white.opacity(0.9),
                            in: Capsule())
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.colorSet4, lineWidth: 3)
                )
                .tint(Color.colorSet4)
            }
            .padding(.bottom, 10)
        }
        .alert("Save Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
}

private extension view_newCocktail {
    func save() {
        do {
            newCocktailIngredients = newCocktailIngredients.map { ingredient in
                ingredient.name = ingredient.name.lowercased()
                ingredient.assignTagBasedOnName()
                return ingredient
            }
            
            let newCocktail = Cocktail(name: newCocktailName.lowercased(), creator: newCocktailCreator.lowercased(), style: newCocktailStyle, ingredients: newCocktailIngredients, comment: newCocktailComment, image: newCocktailImage ?? nil, cocktailCategory: newCocktailCategory)
            
            modelContext.insert(newCocktail)
            try modelContext.save()
            
            Task {
                await service.createCocktail(newCocktail)
                await service.syncPendingUploads(context: modelContext)
            }
            
            dismiss()
        } catch {
            errorMessage = "Failed to save cocktail: \(error.localizedDescription)"
            showError = true
        }
    }
    
    func cancel() {
        dismiss()
    }
}

#Preview {
    view_newCocktail()
}

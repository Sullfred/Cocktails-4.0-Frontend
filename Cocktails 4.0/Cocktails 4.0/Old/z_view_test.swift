//
//  z_view_test.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 15/08/2025.
//

import Foundation
import SwiftData
import SwiftUI
import PhotosUI
/*

struct test_view_newCocktail: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State var selectedPhoto : PhotosPickerItem?
    
    @State private var newCocktailImage: Data?
    @State private var newCocktailName: String = ""
    @State private var newCocktailStyle: Style = .shaken
    @State private var newCocktailIngredients: [Ingredient] = []
    @State private var newIngredientItemName: String = ""
    @State private var newIngredientVolume: Double = 0
    @State private var newIngredientUnit: Iunit = .ml
    @State private var newCocktailCreator: String = ""
    @State private var newCocktailComment: String = ""
    
    
    var body: some View {
        Form{
            //Photo
            Section{
                if let photoData = newCocktailImage, let uiImage = UIImage(data: photoData) {
                    view_imageContainer(image: uiImage, size: 200)
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
            }header: {
                Text("Info").font(.headline)
            }.foregroundStyle(.black)
            
            // Ingredients
            Section {
                // Ingredient List with editing & drag support
                List {
                    ForEach($newCocktailIngredients) { $ingredient in
                        HStack {
                            Image(systemName: "line.horizontal.3")
                                .foregroundColor(.gray)
                                .padding(.trailing, 4)

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
                            .frame(width: 60)

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
                    .onMove { indices, newOffset in
                        withAnimation {
                            newCocktailIngredients.move(fromOffsets: indices, toOffset: newOffset)
                        }
                    }
                    .moveDisabled(false)

                }
                .frame(maxHeight: 250) // optional: limit list height to avoid UI overflow
                .scrollDisabled(true) // disables inner scrolling, use outer scroll

                // Ingredient input row
                HStack {
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

                    TextField("New ingredient", text: $newIngredientItemName)
                        .foregroundStyle(.black)

                    Divider()

                    Button(action: {
                        withAnimation {
                            let ingredient = Ingredient(volume: newIngredientVolume,
                                                        unit: newIngredientUnit,
                                                        name: newIngredientItemName.lowercased())
                            ingredient.assignTagBasedOnName()
                            newCocktailIngredients.append(ingredient)
                            newIngredientVolume = 0
                            newIngredientItemName = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                    }
                    .disabled(newIngredientItemName.isEmpty)
                    .buttonStyle(PlainButtonStyle())
                    .tint(.colorSet4)
                }
            }
            header: {
                Text("Ingredients")
                    .font(.headline)
                    .foregroundStyle(.black)
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
                .foregroundStyle(Color.colorSet5)
                .frame(width: 100, height: 30)
                .background(.white.opacity(0.9),
                            in: Capsule())
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.colorSet5, lineWidth: 3)
                )
                
                Spacer().frame(width: 80)
                
                Button("Save") {
                    save()
                }
                .disabled(newCocktailName.isEmpty || newCocktailIngredients.isEmpty)
                .padding(8)
                .foregroundStyle(Color.colorSet4)
                .frame(width: 100, height: 30)
                .background(.white.opacity(0.9),
                            in: Capsule())
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.colorSet4, lineWidth: 3)
                )
            }
            .padding(.bottom, 10)
        }
        //.tint(.blue)
    }
}

private extension test_view_newCocktail {
    func save() {
        let newCocktail = Cocktail(name: newCocktailName.lowercased(), creator: newCocktailCreator.lowercased(), style: newCocktailStyle, ingredients: newCocktailIngredients, comment: newCocktailComment, favorite: false, image: newCocktailImage ?? nil)
                
        modelContext.insert(newCocktail)
        do {
            try modelContext.save()
        } catch {
            print("Failed to save cocktail")
        }
        
        dismiss()
    }
    
    func cancel() {
        dismiss()
    }
}

#Preview {
    test_view_newCocktail()
}
*/



/*
struct CustomOption: Identifiable, Hashable {
    let id = UUID()
    let text: String
}

struct test_View: View {
    let customOptions = [CustomOption(text: "Option 1"), CustomOption(text: "Option 2"), CustomOption(text: "Option 3"), CustomOption(text: "Option 4"), CustomOption(text: "Option 5")]
    @State var selectedOptions = [CustomOption?]()
    @State var selectedTags = [IngredientTag?]()
    
    var body: some View {
        VStack {
            // This gives us a horizontal stack of buttons that turn blue when selected
            /*
            HStack {
                MultiSelectButtonView(customOptions, $selectedOptions) { item in
                    Text(String(describing: item.text))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(selectedOptions.contains(item) ? .blue : .gray.opacity(0.3))
                        .foregroundColor(selectedOptions.contains(item) ? .white : .primary)
                        .cornerRadius(8)
                }
            }
             */
            
            // This gives us an example of a checkbox
            MultiSelectButtonView(customOptions, $selectedOptions) { item in
                HStack {
                    Image(systemName: selectedOptions.contains(item) ? "checkmark.square.fill" : "square")
                        .foregroundStyle(selectedOptions.contains(item) ? .blue : .primary)
                    Text(String(describing: item.text))
                }
            }
            
            Text("Selected: \(selectedOptions.map { String(describing: $0!.text) }.joined(separator: ", "))")
            
            MultiSelectButtonView(IngredientTag.allCases, $selectedTags) { item in
                HStack {
                    Image(systemName: selectedTags.contains(item) ? "checkmark.square.fill" : "square")
                        .foregroundStyle(selectedTags.contains(item) ? .blue : .primary)
                    Text(String(describing: item.rawValue.capitalized))
                }
            }
        }
        .padding()
    }
}
 */

struct test_View: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var bars: [myBar]
    
    var category: BarItemCategory = .juice
    
    var body: some View {
        ForEach(bars.first?.myBarItems ?? []){ item in
            if item.category == category {
                Text(item.name.capitalized)
                
                Spacer()
                
                Divider()
                
                Button(action: {
                    withAnimation {
                        bars.first?.myBarItems.removeAll { $0.id == item.id }
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundStyle(.colorSet5)
                }
                .buttonStyle(PlainButtonStyle())
                
            }
        }
    }
}

#Preview {
    test_View()
}

//
//  view_Cocktails.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/07/2025.
//

import SwiftUI
import SwiftData

struct old_view_cocktailsList: View {
    @Environment(\.modelContext) var modelContext
    
    @State private var path = [Cocktail]()
    @State private var sortOrder = SortDescriptor(\Cocktail.name)
    @State private var searchText = ""
    @State private var showFavoritesOnly = false
    @State private var selectedTags = [IngredientTag]()
    let selectedCategory: CocktailCategory?
    
    var body: some View {
        NavigationStack(path: $path) {
            old_view_cocktailList(sort: sortOrder, searchString: searchText, showFavoritesOnly: showFavoritesOnly, selectedCategory: selectedCategory)
                .navigationTitle("Cocktails 4.0")
                .navigationDestination(for: Cocktail.self, destination: view_cocktailDetails.init)
                .searchable(text: $searchText, prompt: "Search cocktails")
                .background(Color.colorSet2)
                .toolbarBackground(Color.colorSet1, for: .navigationBar)
                .toolbarBackground(.visible, for: .tabBar)
                .toolbar {
                    ToolbarItem {
                        NavigationLink(destination: view_newCocktail()) {
                            Button(action: {}) {
                                Label("Add Cocktail", systemImage: "plus")
                            }
                        }
                    }
                    //Sort options
                    ToolbarItem(){
                        
                        Menu("Sort", systemImage: "arrow.up.arrow.down") {
                            
                            Section("Display"){
                                
                                Toggle("Show Favorites only", systemImage: showFavoritesOnly ? "heart.fill" : "heart", isOn: $showFavoritesOnly)
                            }
                            
                            // Sorting
                            Section("Sort by"){
                                
                                Picker("Sort by", selection: $sortOrder) {
                                    Text("Name")
                                        .tag(SortDescriptor(\Cocktail.name))
                                    
                                    Text("Created by")
                                        .tag(SortDescriptor(\Cocktail.creator))
                                }
                                .pickerStyle(.inline)
                                .labelsVisibility(.visible)
                            }
                            
                            
                            Section("Base spirit"){
                                
                            }
                        }
                        .menuActionDismissBehavior(.disabled)
                    }
                }
        }
        .tint(.colorSet4)
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    old_view_cocktailsList(selectedCategory: nil)
}

//
//  view_cocktailsFrontPage.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 18/08/2025.
//

import SwiftUI

struct view_cocktailsFrontPage: View {
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    private let tagColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                NavigationLink {
                    view_cocktailsList(selectedCategory: nil) // nil means show all
                } label: {
                    CategoryCard(
                        title: "All Cocktails",
                        imageName: "cocktail_all",
                        uiHeight: 180,
                        iHeight: 150
                    )
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                
                LazyVGrid(columns: columns, spacing: 20) {
                    // One card per category
                    ForEach(CocktailCategory.allCases, id: \.self) { category in
                        NavigationLink {
                            view_cocktailsList(selectedCategory: category)
                        } label: {
                            CategoryCard(
                                title: category.rawValue,
                                imageName: category.imageName,
                                uiHeight: 180,
                                iHeight: 150
                            )
                        }
                    }
                }
                .padding()
                
                Text("Base Spirit")
                    .font(.title2)
                
                LazyVGrid(columns: tagColumns, spacing: 20) {
                    // One card per Tag
                    ForEach(IngredientTag.allCases, id: \.self) { tag in
                        NavigationLink {
                            view_cocktailsList(selectedCategory: nil, baseSpirit: tag)
                        } label: {
                            CategoryCard(
                                title: tag.rawValue,
                                imageName: tag.imageName,
                                uiHeight: 120,
                                iHeight: 90
                            )
                        }
                    }
                }
                .padding()
                
                HStack {
                    NavigationLink(destination: view_deletedCocktails()) {
                        Label("Deleted cocktails", systemImage: "trash.square")
                    }
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Cocktails")
            .background(Color.colorSet2)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: view_newCocktail()) {
                        Button(action: {}) {
                            Label("Add Cocktail", systemImage: "plus")
                        }
                    }
                }
            }
        }
        .tint(.colorSet4)
    }
}

extension CocktailCategory {
    var imageName: String {
        switch self {
        case .mocktail:
            return "mocktail_sample"
        case .tiki:
            return "tiki_sample"
        case .sour:
            return "sour_sample"
        case .highball:
            return "highball_sample"
        case .spiritForward:
            return "spiritforward_sample"
        case .duos:
            return "duos_sample"
        case .champagne:
            return "champagne_sample"
        case .juleps:
            return "juleps_sample"
        case .dessert:
            return "dessert_sample"
        case .other:
            return "other_sample"
        }
    }
}

extension IngredientTag {
    var imageName: String {
        switch self {
        case .brandy:
            return "brandy_sample"
        case .gin:
            return "gin_sample"
        case .rum:
            return "rum_sample"
        case .tequila:
            return "tequila_sample"
        case .vodka:
            return "vodka_sample"
        case .whiskey:
            return "whiskey_sample"
        }
    }
}

#Preview {
    view_cocktailsFrontPage()
}

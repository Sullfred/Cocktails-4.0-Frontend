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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                NavigationLink {
                    view_cocktailsList(selectedCategory: nil) // nil means show all
                } label: {
                    CategoryCard(
                        title: "All Cocktails",
                        imageName: "cocktail_all" // replace with your asset
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
                                imageName: category.imageName
                            )
                        }
                    }
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
        case .duosAndTrios:
            return "duos_sample"
        case .champagne:
            return "champagne_sample"
        case .juleps:
            return "juleps_sample"
        case .cobbler:
            return "cobblers_sample"
        case .other:
            return "other_sample"
        }
    }
}

#Preview {
    view_cocktailsFrontPage()
}

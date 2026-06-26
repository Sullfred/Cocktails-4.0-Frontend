//
//  view_cocktailsFrontPage.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 18/08/2025.
//

import SwiftUI
import SwiftData

struct CocktailsFrontPage: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myBarViewModel: MyBarViewModel
    @EnvironmentObject var cocktailViewModel: CocktailViewModel
    
    @State private var showCreateNewCocktail: Bool = false
    
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
                    view_cocktailsList(selectedCategory: nil) // Show all cocktails
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
                                title: tag.rawValue.capitalized,
                                imageName: tag.imageName,
                                uiHeight: 90,
                                iHeight: 90
                            )
                        }
                    }
                }
                .padding()
                
                HStack {
                    NavigationLink(destination: view_removedCocktails().environmentObject(myBarViewModel)) {
                        Label("Removed cocktails", systemImage: "trash.square")
                    }
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Cocktails")
            .background(Color.colorSet2)
            .toolbar {
                if (userViewModel.canCreateCocktails) {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            checkBeforeGoToNewCocktailView()
                        }) {
                            Label("Add Cocktail", systemImage: "plus")
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $showCreateNewCocktail){
                view_newCocktail()
            }
        }
        .tint(.colorSet4)
    }
    
    private func checkBeforeGoToNewCocktailView() {
        if userViewModel.currentUser != nil {
            toggleIfAuthenticated(isAuthenticated: userViewModel.isLoggedIn, toggleVar: &showCreateNewCocktail)
        }
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
    // Create an in-memory model container for previews
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MyBar.self, configurations: config)
    let context = container.mainContext
    
    let dependencies = AppDependencies(context: context)
    let myBarVM = MyBarViewModel(dependencies: dependencies)
    let cocktailVM = CocktailViewModel(dependencies: dependencies)
    
    CocktailsFrontPage()
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
        .environmentObject(myBarVM)
        .environmentObject(cocktailVM)
}

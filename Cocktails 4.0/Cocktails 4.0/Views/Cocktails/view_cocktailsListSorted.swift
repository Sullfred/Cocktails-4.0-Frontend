//
//  view_cocktailsListSorted.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 18/08/2025.
//

import SwiftUI
import SwiftData

struct view_cocktailsListSorted: View {
    @Environment(\.modelContext) private var context
    
    @EnvironmentObject var loginViewModel: LoginViewModel
    @EnvironmentObject var myBarViewModel: MyBarViewModel
    
    let selectedCategory: CocktailCategory?
    var baseSpirit: IngredientTag?
    var showCraftableOnly: Bool
    let searchTerms: [String]
    var showFavoritesOnly: Bool
    
    @Query(sort: [
        SortDescriptor(\Cocktail.name),
        SortDescriptor(\Cocktail.creator)
    ]) var allCocktails: [Cocktail]
    
    private var filteredCocktails: [Cocktail] {
        let barItems = Set(myBarViewModel.personalBar.myBarItems.map { canonicalName(for: $0.name) })
        let favorites = Set(myBarViewModel.personalBar.favoriteCocktails)
        
        return allCocktails.filter { cocktail in
            (selectedCategory == nil || cocktail.cocktailCategory == selectedCategory)
            &&
            (baseSpirit == nil || cocktail.ingredients.contains { ingredient in
                ingredient.tag == baseSpirit
            })
            &&
            (!showCraftableOnly || cocktail.ingredients.allSatisfy { ingredient in
                matchesIngredient(ingredient.name, barItems: barItems)
            })
            &&
            (!showFavoritesOnly || favorites.contains(cocktail.id.uuidString))
            &&
            (searchTerms.isEmpty || searchTerms.allSatisfy { term in
                cocktail.name.localizedStandardContains(term) ||
                cocktail.ingredients.contains { ingredient in
                    ingredient.name.localizedStandardContains(term)
                }
            })
            && !myBarViewModel.personalBar.removedCocktails.contains(where: {$0.id == cocktail.id.uuidString})
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredCocktails) { cocktail in
                NavigationLink(destination: view_cocktailDetails(cocktail: cocktail)
                    .environmentObject(loginViewModel)
                    .environmentObject(myBarViewModel)) {
                    VStack(alignment: .leading) {
                        cocktailListItem(cocktail: cocktail)
                            .environmentObject(myBarViewModel)
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        removeFromList(cocktail)
                    } label: {
                        Label("Remove from List", systemImage: "trash")
                    }
                    .tint(.red)
                }
            }
            .listRowBackground(Color.clear)
        }
        .refreshable {
            if await CocktailService.shared.checkServerConnection() {
                await CocktailService.shared.fetchCocktails(context: context)
            }
        }
    }
    
    init(sortOrder: [SortDescriptor<Cocktail>], searchText: String, showFavoritesOnly: Bool, showCraftableOnly: Bool, selectedCategory: CocktailCategory?, baseSpirit: IngredientTag?) {
        self.selectedCategory = selectedCategory
        self.baseSpirit = baseSpirit
        self.showCraftableOnly = showCraftableOnly
        self.showFavoritesOnly = showFavoritesOnly
        
        self.searchTerms = searchText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
        
        _allCocktails = Query(filter: #Predicate<Cocktail> { cocktail in
            searchText.isEmpty ||
            searchText.contains(",") ||
            cocktail.name.localizedStandardContains(searchText) ||
            cocktail.ingredients.contains { ingredient in
                ingredient.name.localizedStandardContains(searchText)
            }
        }, sort: sortOrder)
    }
}

private extension view_cocktailsListSorted {
    func canonicalName(for ingredient: String) -> String {
        let lowercased = ingredient.lowercased()
        let ingredientGroups = loadIngredientGroups()
        for (canonical, variants) in ingredientGroups {
            if canonical == lowercased || variants.contains(lowercased) {
                return canonical
            }
        }
        return lowercased
    }
    
    func matchesIngredient(_ ingredient: String, barItems: Set<String>) -> Bool {
        let canonicalIngredientName = canonicalName(for: ingredient)
        if barItems.contains(canonicalIngredientName) {
            return true
        }
        for barItem in barItems {
            if barItem.contains(canonicalIngredientName) || canonicalIngredientName.contains(barItem) {
                return true
            }
        }
        return false
    }
    
    func deleteCocktail(_ indexSet: IndexSet) {
        for index in indexSet {
            let cocktail = allCocktails[index]
            removeFromList(cocktail)
        }
    }

    func removeFromList(_ cocktail: Cocktail) {
        Task {
            let removed = RemovedCocktail(id: cocktail.id.uuidString, name: cocktail.name, creator: cocktail.creator)
            await myBarViewModel.addRemoved(removed)
        }
    }
    
    func loadIngredientGroups() -> [String: [String]] {
        guard let url = Bundle.main.url(forResource: "IngredientGroups", withExtension: "json") else {
            return [:]
        }
        do {
            let data = try Data(contentsOf: url)
            let groups = try JSONDecoder().decode([String: [String]].self, from: data)
            return groups
        } catch {
            return [:]
        }
    }
}

#Preview {
    view_cocktailsListSorted(sortOrder: [
        SortDescriptor(\Cocktail.name),
        SortDescriptor(\Cocktail.creator)
    ], searchText: "", showFavoritesOnly: false, showCraftableOnly: false, selectedCategory: nil, baseSpirit: nil)
    .environmentObject({
        let vm = LoginViewModel()
        vm.currentUser = LoggedInUser(
            id: UUID(),
            username: "Daniel Vang Kleist",
            addPermission: false,
            editPermissions: false,
            adminRights: false
        )
        return vm
    }())
}

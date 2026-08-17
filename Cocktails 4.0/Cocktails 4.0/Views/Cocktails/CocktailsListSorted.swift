//
//  view_cocktailsListSorted.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 18/08/2025.
//

import SwiftUI
import SwiftData

struct CocktailsListSorted: View {
    @EnvironmentObject var cocktailViewModel: CocktailViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myBarViewModel: MyBarViewModel
    @StateObject private var listViewModel = CocktailListViewModel()
    
    let selectedCategory: CocktailCategory?
    var baseSpirit: IngredientTag?
    var showCraftableOnly: Bool
    let searchTerms: [String]
    var showFavoritesOnly: Bool
    
    private var filterCriteria: CocktailFilterCriteria {
        CocktailFilterCriteria(
            searchTerms: searchTerms,
            showFavoritesOnly: showFavoritesOnly,
            showCraftableOnly: showCraftableOnly,
            selectedCategory: selectedCategory,
            baseSpirit: baseSpirit
        )
    }
    
    private var filteredCategory: [CocktailCategory] {
        if let selected = selectedCategory {
            return [selected]
        } else {
            return CocktailCategory.allCases
        }
    }
    
    @Query(sort: [
        SortDescriptor(\Cocktail.name),
        SortDescriptor(\Cocktail.creator)
    ]) var allCocktails: [Cocktail]
    
    
    var body: some View {
        List {
            ForEach(filteredCategory, id: \.self) { category in
                let cocktailsInCategory = listViewModel.visibleCocktails.filter {
                    $0.cocktailCategory == category
                }
                if !cocktailsInCategory.isEmpty {
                    Section(header: selectedCategory == nil ? categoryHeader(category) : nil) {
                        ForEach(cocktailsInCategory) { cocktail in
                            NavigationLink(destination: CocktailDetails(cocktail: cocktail)) {
                                    VStack(alignment: .leading) {
                                        cocktailListItem(cocktail: cocktail)
                                    }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        removeFromList(cocktail)
                                    } label: {
                                        Label("cocktails_remove_list", systemImage: "trash")
                                    }
                                    .tint(.red)
                                }
                        }
                        .listRowBackground(Color.clear)
                    }
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await cocktailViewModel.refresh()
        }
        .onAppear {
            updateSourceData()
            listViewModel.setCriteria(filterCriteria)
        }

        .onChange(of: allCocktails) { _, _ in
            updateSourceData()
        }

        .onChange(of: myBarViewModel.personalBar) { _, _ in
            updateSourceData()
        }
        .onChange(of: filterCriteria) { _, newCriteria in
            listViewModel.setCriteria(newCriteria)
        }
    }
    
    init(sortOrder: [SortDescriptor<Cocktail>], searchText: String, showFavoritesOnly: Bool, showCraftableOnly: Bool, selectedCategory: CocktailCategory?, baseSpirit: IngredientTag?) {
        self.selectedCategory = selectedCategory
        self.baseSpirit = baseSpirit
        self.showCraftableOnly = showCraftableOnly
        self.showFavoritesOnly = showFavoritesOnly
        
        let rawTerms = searchText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { $0.count >= 2 }
        var unique: [String] = []
        var seen = Set<String>()
        for term in rawTerms where !seen.contains(term) {
            unique.append(term)
            seen.insert(term)
        }
        self.searchTerms = unique
        
        _allCocktails = Query(sort: sortOrder)
    }
}

@ViewBuilder
private func categoryHeader(_ category: CocktailCategory) -> some View {
    HStack {
        Text(category.rawValue.capitalized)
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(Color.textPrimary)
        Spacer()
    }
    .padding(.vertical, 6)
    .frame(maxWidth: .infinity, alignment: .leading)
}

private extension CocktailsListSorted {
    func updateSourceData() {
        listViewModel.update(
            cocktails: allCocktails,
            personalBar: myBarViewModel.personalBar
        )
    }
    
    func hideCocktail(_ indexSet: IndexSet) {
        for index in indexSet {
            let cocktail = allCocktails[index]
            removeFromList(cocktail)
        }
    }
    
    func removeFromList(_ cocktail: Cocktail) {
        Task {
            let removed = HiddenCocktail(cocktailId: cocktail.id.uuidString, name: cocktail.name, creator: cocktail.creator)
            await myBarViewModel.addRemoved(removed)
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
    
    CocktailsListSorted(sortOrder: [
        SortDescriptor(\Cocktail.name),
        SortDescriptor(\Cocktail.creator)
    ], searchText: "", showFavoritesOnly: false, showCraftableOnly: false, selectedCategory: nil, baseSpirit: nil)
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
}


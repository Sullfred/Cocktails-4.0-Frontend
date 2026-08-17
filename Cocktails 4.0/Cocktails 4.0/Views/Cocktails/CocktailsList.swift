import SwiftUI
import SwiftData

struct CocktailsList: View {
    @EnvironmentObject var cocktailViewModel: CocktailViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myBarViewModel: MyBarViewModel

    @State private var path: [Cocktail] = []
    @State private var showCreateNewCocktail: Bool = false
    
    @State private var sortOrder = [
        SortDescriptor(\Cocktail.name),
        SortDescriptor(\Cocktail.creator)
    ]
    @State private var searchText: String = ""
    @State private var showFavoritesOnly: Bool = false
    @State private var showCraftableOnly: Bool = false
    let selectedCategory: CocktailCategory?
    @State var baseSpirit: IngredientTag?
    
    var baseSpiritLabel: String {
        guard let spirit = baseSpirit else {
            return NSLocalizedString("all", comment: "")
        }
        return spirit.rawValue.capitalized
    }
    
    var body: some View {
        CocktailsListSorted(sortOrder: sortOrder, searchText: searchText, showFavoritesOnly: showFavoritesOnly, showCraftableOnly: showCraftableOnly, selectedCategory: selectedCategory, baseSpirit: baseSpirit)
            .navigationTitle(
                selectedCategory != nil
                    ? LocalizedStringKey(selectedCategory?.rawValue ?? "error")
                    : LocalizedStringKey("cocktails_all")
            )
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always)) //Will fix flicker when navigating
            .background(Color.background)
            .scrollContentBackground(.hidden)
            .toolbar {
                if (userViewModel.canCreateCocktails){
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            checkBeforeGoToNewCocktailView()
                        }) {
                            Label("cocktails_add", systemImage: "plus")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Section("cocktails_menu"){
                            if userViewModel.currentUser != nil {
                                Toggle("cocktails_menu_favorites", systemImage: showFavoritesOnly ? "heart.fill" : "heart", isOn: $showFavoritesOnly)
                            
                                Toggle("cocktails_menu_creatables", systemImage: showCraftableOnly ? "wineglass.fill" : "wineglass", isOn: $showCraftableOnly)
                            }
                        }
                        
                        Section("cocktails_menu_sort") {
                            Picker("cocktails_menu_sort", selection: $sortOrder) {
                                Text("info_name")
                                    .tag([
                                        SortDescriptor(\Cocktail.name),
                                        SortDescriptor(\Cocktail.creator)
                                    ])
                                
                                Text("creator")
                                    .tag([
                                        SortDescriptor(\Cocktail.creator),
                                        SortDescriptor(\Cocktail.name)
                                    ])
                            }
                            .pickerStyle(.inline)
                            .labelsVisibility(.visible)
                        }
                        
                        Section("base_spirit") {
                            Picker(baseSpiritLabel, selection: $baseSpirit) {
                                Text("all").tag(nil as IngredientTag?)
                                ForEach(IngredientTag.allCases, id: \.self) { tag in
                                    Text(tag.rawValue.capitalized).tag(tag as IngredientTag?)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    } label: {
                        Label("sort", systemImage: "arrow.up.arrow.down")
                    }
                    .menuActionDismissBehavior(.disabled)
                }
            }
            .navigationDestination(isPresented: $showCreateNewCocktail){
                NewCocktail()
            }
            .tint(.textPrimary)
    }
    
    private func checkBeforeGoToNewCocktailView() {
        if userViewModel.currentUser != nil {
            toggleIfAuthenticated(isAuthenticated: userViewModel.isLoggedIn, toggleVar: &showCreateNewCocktail)
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
    
    CocktailsList(selectedCategory: nil, baseSpirit: nil)
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

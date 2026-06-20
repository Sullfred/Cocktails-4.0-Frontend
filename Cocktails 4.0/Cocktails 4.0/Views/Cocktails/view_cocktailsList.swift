import SwiftUI
import SwiftData

struct view_cocktailsList: View {
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

    var body: some View {
        view_cocktailsListSorted(sortOrder: sortOrder, searchText: searchText, showFavoritesOnly: showFavoritesOnly, showCraftableOnly: showCraftableOnly, selectedCategory: selectedCategory, baseSpirit: baseSpirit)
            .navigationTitle(selectedCategory != nil ? selectedCategory?.rawValue ?? "error" : "All Cocktails")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always)) //Will fix flicker when navigating
            .background(Color.colorSet2)
            .scrollContentBackground(.hidden)
            .toolbar {
                if (userViewModel.canCreateCocktails){
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            checkBeforeGoToNewCocktailView()
                        }) {
                            Label("Add Cocktail", systemImage: "plus")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Section("Display"){
                            
                            Toggle("Show Favorites only", systemImage: showFavoritesOnly ? "heart.fill" : "heart", isOn: $showFavoritesOnly)
                            
                            if userViewModel.currentUser != nil {
                                Toggle("Show Craftables only", systemImage: showCraftableOnly ? "wineglass.fill" : "wineglass", isOn: $showCraftableOnly)
                            }
                        }
                        
                        Section("Sort by") {
                            Picker("Sort by", selection: $sortOrder) {
                                Text("Name")
                                    .tag([
                                        SortDescriptor(\Cocktail.name),
                                        SortDescriptor(\Cocktail.creator)
                                    ])
                                
                                Text("Creator")
                                    .tag([
                                        SortDescriptor(\Cocktail.creator),
                                        SortDescriptor(\Cocktail.name)
                                    ])
                            }
                            .pickerStyle(.inline)
                            .labelsVisibility(.visible)
                        }
                        
                        Section("Base Spirit") {
                            Picker("Base Spirit", selection: $baseSpirit) {
                                Text("All").tag(nil as IngredientTag?)
                                ForEach(IngredientTag.allCases, id: \.self) { tag in
                                    Text(tag.rawValue.capitalized).tag(tag as IngredientTag?)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                    .menuActionDismissBehavior(.disabled)
                }
            }
            .navigationDestination(isPresented: $showCreateNewCocktail){
                view_newCocktail()
            }
            .tint(.colorSet4)
    }
    
    private func checkBeforeGoToNewCocktailView() {
        if userViewModel.currentUser != nil {
            toggleIfAuthenticated(isAuthenticated: userViewModel.requireAuth, toggleVar: &showCreateNewCocktail)
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
    
    view_cocktailsList(selectedCategory: nil, baseSpirit: nil)
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

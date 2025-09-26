import SwiftUI
import SwiftData

struct view_cocktailsList: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var loginViewModel: LoginViewModel

    @State private var path: [Cocktail] = []
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
            .environmentObject(loginViewModel)
            .navigationTitle(selectedCategory != nil ? selectedCategory?.rawValue ?? "error" : "All Cocktails")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always)) //Will fix flicker when navigating
            .background(Color.colorSet2)
            .scrollContentBackground(.hidden)
            .toolbar {
                if (loginViewModel.currentUser?.addPermission ?? false) == true {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: view_newCocktail()) {
                            Label("Add Cocktail", systemImage: "plus")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Section("Display"){
                            
                            Toggle("Show Favorites only", systemImage: showFavoritesOnly ? "heart.fill" : "heart", isOn: $showFavoritesOnly)
                            
                            Toggle("Show Craftables only", systemImage: showCraftableOnly ? "wineglass.fill" : "wineglass", isOn: $showCraftableOnly)
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
            .tint(.colorSet4)
    }
}

#Preview {
    view_cocktailsList(selectedCategory: nil, baseSpirit: nil)
        .environmentObject({
            let vm = LoginViewModel()
            vm.currentUser = LoggedInUser(
                username: "Daniel Vang Kleist",
                addPermission: false,
                editPermissions: false,
                adminRights: false
            )
            return vm
        }())
}

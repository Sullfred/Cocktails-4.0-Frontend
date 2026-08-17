import Testing
@testable import Cocktails_4_0

@Suite("CocktailListViewModel filtering")
@MainActor
struct CocktailListViewModelTests {

    private func makeIngredient(_ name: String, tag: IngredientTag? = nil, order: Int = 0) -> Ingredient {
        let ing = Ingredient(volume: 30, unit: .ml, name: name, orderIndex: order)
        ing.tag = tag
        return ing
    }

    private func makeCocktail(
        name: String,
        creator: String = "",
        category: CocktailCategory,
        ingredients: [Ingredient]
    ) -> Cocktail {
        return Cocktail(
            name: name,
            creator: creator,
            style: .shaken,
            ingredients: ingredients,
            comment: "",
            image: nil,
            cocktailCategory: category
        )
    }

    @Test("Filters by base spirit (ingredient tag)")
    func filtersByBaseSpirit() async throws {
        let bourbon = makeIngredient("bourbon", tag: .whiskey)
        let gin = makeIngredient("london dry gin", tag: .gin)
        let lemon = makeIngredient("lemon juice")
        let syrup = makeIngredient("simple syrup")

        let whiskeySour = makeCocktail(name: "whiskey sour", category: .sour, ingredients: [bourbon, lemon, syrup])
        let ginFizz = makeCocktail(name: "gin fizz", category: .highball, ingredients: [gin, lemon, syrup])

        let vm = CocktailListViewModel(searchManager: SearchManager(ingredientGroups: [:]))
        vm.update(cocktails: [whiskeySour, ginFizz], personalBar: .empty)
        vm.setCriteria(CocktailFilterCriteria(searchTerms: [], showFavoritesOnly: false, showCraftableOnly: false, selectedCategory: nil, baseSpirit: .whiskey))

        #expect(vm.visibleCocktails.count == 1)
        #expect(vm.visibleCocktails.first?.name == "whiskey sour")
    }

    @Test("Filters by category and search terms")
    func filtersByCategoryAndSearch() async throws {
        let bourbon = makeIngredient("bourbon", tag: .whiskey)
        let rum = makeIngredient("jamaican rum", tag: .rum)
        let lemon = makeIngredient("lemon juice")
        let syrup = makeIngredient("simple syrup")

        let whiskeySour = makeCocktail(name: "whiskey sour", creator: "daniel", category: .sour, ingredients: [bourbon, lemon, syrup])
        let daiquiri = makeCocktail(name: "daiquiri", creator: "hemingway", category: .other, ingredients: [rum, lemon, syrup])

        let vm = CocktailListViewModel(searchManager: SearchManager(ingredientGroups: [:]))
        vm.update(cocktails: [whiskeySour, daiquiri], personalBar: .empty)
        vm.setCriteria(CocktailFilterCriteria(searchTerms: ["daniel"], showFavoritesOnly: false, showCraftableOnly: false, selectedCategory: .sour, baseSpirit: nil))

        #expect(vm.visibleCocktails.count == 1)
        #expect(vm.visibleCocktails.first?.name == "whiskey sour")
    }

    @Test("Filters craftable only using bar items")
    func filtersCraftableOnly() async throws {
        let bourbon = makeIngredient("bourbon", tag: .whiskey)
        let lemon = makeIngredient("lemon juice")
        let syrup = makeIngredient("simple syrup")
        let egg = makeIngredient("egg white")
        let cola = makeIngredient("cola")

        let whiskeySour = makeCocktail(name: "whiskey sour", category: .sour, ingredients: [bourbon, lemon, syrup, egg])
        let highball = makeCocktail(name: "whiskey highball", category: .highball, ingredients: [bourbon, cola])

        let barItems = ["bourbon", "lemon juice", "simple syrup", "egg white"].map { MyBarItem(name: $0) }
        var bar = MyBar.empty
        bar.myBarItems = barItems

        let vm = CocktailListViewModel(searchManager: SearchManager(ingredientGroups: [:]))
        vm.update(cocktails: [whiskeySour, highball], personalBar: bar)
        vm.setCriteria(CocktailFilterCriteria(searchTerms: [], showFavoritesOnly: false, showCraftableOnly: true, selectedCategory: nil, baseSpirit: nil))

        #expect(vm.visibleCocktails.count == 1)
        #expect(vm.visibleCocktails.first?.name == "whiskey sour")
    }

    @Test("Filters favorites and excludes removed")
    func filtersFavoritesAndRemoved() async throws {
        let bourbon = makeIngredient("bourbon", tag: .whiskey)
        let lemon = makeIngredient("lemon juice")
        let syrup = makeIngredient("simple syrup")

        let whiskeySour = makeCocktail(name: "whiskey sour", category: .sour, ingredients: [bourbon, lemon, syrup])
        let oldFashioned = makeCocktail(name: "old fashioned", category: .spiritForward, ingredients: [bourbon, syrup])

        var bar = MyBar.empty
        bar.favoriteCocktails = [whiskeySour.id.uuidString]
        bar.removedCocktails = [HiddenCocktail(cocktailId: oldFashioned.id.uuidString, name: oldFashioned.name, creator: oldFashioned.creator)]

        let vm = CocktailListViewModel(searchManager: SearchManager(ingredientGroups: [:]))
        vm.update(cocktails: [whiskeySour, oldFashioned], personalBar: bar)
        vm.setCriteria(CocktailFilterCriteria(searchTerms: [], showFavoritesOnly: true, showCraftableOnly: false, selectedCategory: nil, baseSpirit: nil))

        #expect(vm.visibleCocktails.count == 1)
        #expect(vm.visibleCocktails.first?.id == whiskeySour.id)
    }
}

import Testing
@testable import Cocktails_4_0

@Suite("SearchManager")
struct SearchManagerTests {

    @Test("Canonical name maps variants")
    func canonicalNameMapsVariants() async throws {
        let manager = SearchManager(ingredientGroups: [
            "whiskey": ["bourbon", "rye"],
            "rum": ["jamaican rum", "cuban rum"]
        ])

        #expect(manager.canonicalName(for: "Bourbon") == "whiskey")
        #expect(manager.canonicalName(for: "jamaican rum") == "rum")
        #expect(manager.canonicalName(for: "gin") == "gin")
    }

    @Test("Ingredient match succeeds with canonicalization and contains")
    func ingredientMatch() async throws {
        let manager = SearchManager(ingredientGroups: [
            "whiskey": ["bourbon", "rye"]
        ])

        let barItems: Set<String> = ["Bourbon", "lemon", "syrup"]
        #expect(manager.matchesIngredient("whiskey", barItems: barItems))
        #expect(manager.matchesIngredient("bourbon", barItems: barItems))
        #expect(!manager.matchesIngredient("rum", barItems: barItems))
    }

    @Test("Cocktail matches search terms (name, creator, ingredients)")
    func matchesCocktailSearch() async throws {
        let manager = SearchManager(ingredientGroups: [
            "whiskey": ["bourbon"]
        ])

        let ing1 = Ingredient(volume: 30, unit: .ml, name: "bourbon", orderIndex: 0)
        let ing2 = Ingredient(volume: 15, unit: .ml, name: "lemon juice", orderIndex: 1)
        let cocktail = Cocktail(name: "whiskey sour", creator: "daniel", style: .shaken, ingredients: [ing1, ing2], comment: "", image: nil, cocktailCategory: .sour)

        #expect(manager.matches(cocktail: cocktail, searchTerm: "whiskey"))
        #expect(manager.matches(cocktail: cocktail, searchTerm: "dan"))
        #expect(manager.matches(cocktail: cocktail, searchTerm: "lemon"))
        #expect(!manager.matches(cocktail: cocktail, searchTerm: "rum"))
    }
}

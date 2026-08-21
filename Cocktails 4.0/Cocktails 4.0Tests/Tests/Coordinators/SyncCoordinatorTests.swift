import Testing
import Foundation
import SwiftData
@testable import Cocktails_4_0

@MainActor
@Suite("SyncCoordinator Logical Tests")
struct SyncCoordinatorTests {
    
    private func createInMemoryContainer() throws -> (ModelContainer, ModelContext) {
        let schema = Schema([
            Cocktail.self,
            Ingredient.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        let container = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )

        let context = ModelContext(container)

        return (container, context)
    }
    

    @Test("Addition: local has A, server has A+B -> B is inserted")
    func testSyncAddition() throws {
        let (_, context) = try createInMemoryContainer()
        let coordinator = SyncCoordinator(context: context)
        
        let cocktailA = Cocktail(name: "A", creator: "C1", style: .shaken, ingredients: [], comment: "", image: nil, imageURL: nil, cocktailCategory: .other)
        cocktailA.id = UUID()
        context.insert(cocktailA)
        try context.save()
        
        let cocktailB = Cocktail(name: "B", creator: "C2", style: .stirred, ingredients: [], comment: "", image: nil, imageURL: nil, cocktailCategory: .other)
        cocktailB.id = UUID()
        
        let fetched = [cocktailA, cocktailB]
        let result = try coordinator.syncCocktails(fetchedCocktails: fetched)
        
        #expect(result.addedCocktails == ["B"])
        #expect(result.deletedCocktails == [])
        
        let local = try context.fetch(FetchDescriptor<Cocktail>())
        #expect(local.count == 2)
        #expect(local.contains { $0.name == "B" })
    }

    @Test("Deletion: local has A+B, server has A -> B is removed")
    func testSyncDeletion() throws {
        let (_, context) = try createInMemoryContainer()
        let coordinator = SyncCoordinator(context: context)
        
        let cocktailA = Cocktail(name: "A", creator: "C1", style: .shaken, ingredients: [], comment: "", image: nil, imageURL: nil, cocktailCategory: .other)
        cocktailA.id = UUID()
        let cocktailB = Cocktail(name: "B", creator: "C2", style: .stirred, ingredients: [], comment: "", image: nil, imageURL: nil, cocktailCategory: .other)
        cocktailB.id = UUID()
        
        context.insert(cocktailA)
        context.insert(cocktailB)
        try context.save()
        
        let fetched = [cocktailA]
        let result = try coordinator.syncCocktails(fetchedCocktails: fetched)
        
        #expect(result.addedCocktails == [])
        #expect(result.deletedCocktails == ["B"])
        
        let local = try context.fetch(FetchDescriptor<Cocktail>())
        #expect(local.count == 1)
        #expect(local.first?.name == "A")
    }

    @Test("Update: local has A(v1), server has A(v2) -> A updated")
    func testSyncUpdate() throws {
        let (_, context) = try createInMemoryContainer()
        let coordinator = SyncCoordinator(context: context)
        
        let id = UUID()
        let cocktailV1 = Cocktail(name: "V1", creator: "C1", style: .shaken, ingredients: [], comment: "Old", image: nil, imageURL: nil, cocktailCategory: .other)
        cocktailV1.id = id
        context.insert(cocktailV1)
        try context.save()
        
        let cocktailV2 = Cocktail(name: "V2", creator: "C1", style: .shaken, ingredients: [], comment: "New", image: nil, imageURL: nil, cocktailCategory: .other)
        cocktailV2.id = id
        
        let fetched = [cocktailV2]
        let result = try coordinator.syncCocktails(fetchedCocktails: fetched)
        
        #expect(result.addedCocktails == [])
        #expect(result.deletedCocktails == [])
        
        let local = try context.fetch(FetchDescriptor<Cocktail>())
        let updated = try #require(local.first)
        #expect(updated.name == "V2")
        #expect(updated.comment == "New")
    }
}

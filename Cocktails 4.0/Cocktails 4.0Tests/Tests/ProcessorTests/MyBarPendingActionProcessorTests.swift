import Testing
@testable import Cocktails_4_0
import Foundation

@Suite("MyBarPendingActionProcessor")
@MainActor
struct MyBarPendingActionProcessorTests {
    let mockClient = MockAPIClient()

    @Test("canProcess identifies supported types")
    func canProcessTypes() {
        let mockService = MockMyBarService(apiClient: mockClient)
        let processor = MyBarPendingActionProcessor(myBarService: mockService)

        #expect(processor.canProcess(.addBarItem) == true)
        #expect(processor.canProcess(.deleteBarItem) == true)
        #expect(processor.canProcess(.addFavorite) == true)
        #expect(processor.canProcess(.deleteFavorite) == true)
        #expect(processor.canProcess(.addRemoved) == true)
        #expect(processor.canProcess(.deleteRemoved) == true)
        #expect(processor.canProcess(.addCocktail) == false)
        #expect(processor.canProcess(.updateCocktail) == false)
    }

    @Test("process consolidates add and delete actions for bar items")
    func consolidatesBarItems() async throws {
        let mockService = MockMyBarService(apiClient: mockClient)
        let processor = MyBarPendingActionProcessor(myBarService: mockService)

        let item1 = MyBarItemDTO(id: UUID(), name: "Bourbon", category: .liquor)
        let item2 = MyBarItemDTO(id: UUID(), name: "Vermouth", category: .liquor)

        let actions = [
            PendingAction(type: .addBarItem, userId: UUID(), payload: item1),
            PendingAction(type: .addBarItem, userId: UUID(), payload: item2),
            PendingAction(type: .deleteBarItem, userId: UUID(), payload: item1)
        ]
        // Note: PendingAction init sets dateCreated = Date(). 
        // To be precise about ordering, we'd need to mock the date or manually set it.
        // But for basic consolidation, we can assume these are created in order if the loop is fast.
        // However, the processor sorts by dateCreated.

        _ = try await processor.process(actions)

        // item1 was added then deleted -> should not be in addedItems
        #expect(mockService.addedItems.first?.count == 1)
        #expect(mockService.addedItems.first?.first?.id == item2.id)
        #expect(mockService.deletedItemIds.first?.count == 1)
        #expect(mockService.deletedItemIds.first?.first == item1.id)
    }

    @Test("process consolidates favorites")
    func consolidatesFavorites() async throws {
        let mockService = MockMyBarService(apiClient: mockClient)
        let processor = MyBarPendingActionProcessor(myBarService: mockService)

        let fav1 = UUID()
        let fav2 = UUID()

        let actions = [
            PendingAction(type: .addFavorite, userId: UUID(), payload: fav1),
            PendingAction(type: .addFavorite, userId: UUID(), payload: fav2),
            PendingAction(type: .deleteFavorite, userId: UUID(), payload: fav1)
        ]

        _ = try await processor.process(actions)

        #expect(mockService.addedFavorites.first?.count == 1)
        #expect(mockService.addedFavorites.first?.first == fav2)
        #expect(mockService.deletedFavorites.first?.count == 1)
        #expect(mockService.deletedFavorites.first?.first == fav1)
    }

    @Test("process consolidates hidden cocktails")
    func consolidatesHiddenCocktails() async throws {
        let mockService = MockMyBarService(apiClient: mockClient)
        let processor = MyBarPendingActionProcessor(myBarService: mockService)

        let hidden1 = HiddenCocktailDTO(id: UUID(), cocktailId: UUID().uuidString, name: "Secret", creator: "Someone", date: Date())
        let hidden2 = HiddenCocktailDTO(id: UUID(), cocktailId: UUID().uuidString, name: "Hidden", creator: "Someone", date: Date())

        let actions = [
            PendingAction(type: .addRemoved, userId: UUID(), payload: hidden1),
            PendingAction(type: .addRemoved, userId: UUID(), payload: hidden2),
            PendingAction(type: .deleteRemoved, userId: UUID(), payload: hidden1)
        ]

        _ = try await processor.process(actions)

        #expect(mockService.addedHiddenCocktails.first?.count == 1)
        #expect(mockService.addedHiddenCocktails.first?.first?.id == hidden2.id)
        #expect(mockService.deletedHiddenCocktailIds.first?.count == 1)
        #expect(mockService.deletedHiddenCocktailIds.first?.first == hidden1.id)
    }

    /*
    @Test("process throws error for unsupported action types")
    func throwsForInvalidTypes() async throws {
        let mockService = MockMyBarService()
        let processor = MyBarPendingActionProcessor(myBarService: mockService)

        let actions = [
            PendingAction(type: .addCocktail, userId: UUID(), payload: "invalid")
        ]

        await #expect(throws: PendingActionError.invalidPayload) {
            try await processor.process(actions)
        }
    }
     */
}

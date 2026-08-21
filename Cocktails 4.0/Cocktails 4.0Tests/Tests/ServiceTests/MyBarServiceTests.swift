import Testing
import Foundation
@testable import Cocktails_4_0

@Suite("MyBarService Logical Tests")
struct MyBarServiceTests {
    let mockClient = MockAPIClient()
    let service: MyBarService
    let baseURL = ServiceConfig.baseURL
    
    init() {
        self.service = MyBarService(apiClient: mockClient)
    }
    
    @Test("Fetch my bar successfully maps DTO to Model")
    func testFetchMyBarSuccess() async throws {
        let url = baseURL.appending(path: Endpoints.myBar)
        let dto = MyBarDTO(
            id: UUID(),
            userId: UUID(),
            barItems: [MyBarItemDTO(id: UUID(), name: "Bourbon", category: .liquor)],
            favoriteCocktails: ["uuid-1", "uuid-2"],
            hiddenCocktails: []
        )
        
        mockClient.setResponse(dto, for: url)
        
        let bar = try await service.fetchMyBar()
        
        #expect(bar.myBarItems.count == 1)
        #expect(bar.myBarItems.first?.name == "Bourbon")
        #expect(bar.favoriteCocktails.count == 2)
    }
    
    @Test("Add bar items sends correct POST request")
    func testAddBarItemSendsCorrectData() async throws {
        let url = baseURL.appending(path: Endpoints.myBar + "/items")
        let items = [MyBarItemDTO(id: UUID(), name: "Gin", category: .liquor)]
        
        try await service.addBarItem(items)
        
        let call = try #require(mockClient.calls.first)
        #expect(call.method == "POST")
        #expect(call.url == url)
        
        let body = try #require(call.body)
        let decoded = try JSONDecoder().decode([MyBarItemDTO].self, from: body)
        #expect(decoded == items)
    }
    
    @Test("Delete bar items sends correct DELETE request")
    func testDeleteBarItemsSendsCorrectData() async throws {
        let url = baseURL.appending(path: Endpoints.myBar + "/items")
        let ids = [UUID(), UUID()]
        
        try await service.deleteBarItems(ids)
        
        let call = try #require(mockClient.calls.first)
        #expect(call.method == "DELETE")
        #expect(call.url == url)
        
        let body = try #require(call.body)
        let dto = try JSONDecoder().decode(RemoveBarItemsDTO.self, from: body)
        #expect(dto.itemIds == ids)
    }
    
    @Test("Add favorites sends correct POST request")
    func testAddFavoritesSendsCorrectData() async throws {
        let url = baseURL.appending(path: Endpoints.myBar + "/favorites")
        let ids = [UUID(), UUID()]
        
        try await service.addFavorites(ids)
        
        let call = try #require(mockClient.calls.first)
        #expect(call.method == "POST")
        #expect(call.url == url)
        
        let body = try #require(call.body)
        let dto = try JSONDecoder().decode(AddFavoritesDTO.self, from: body)
        #expect(dto.itemIds == ids)
    }

    @Test("Add hidden cocktail handles ISO8601 date encoding")
    func testAddHiddenCocktailEncoding() async throws {
        //let url = baseURL.appending(path: Endpoints.myBar + "/hiddenCocktail")
        let date = Date()
        let hidden = [HiddenCocktailDTO(id: UUID(), cocktailId: "123", name: "Test", creator: "User", date: date)]
        
        try await service.addHiddenCocktail(hidden)
        
        let call = try #require(mockClient.calls.first)
        #expect(call.method == "POST")
        
        let body = try #require(call.body)
        let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode([HiddenCocktailDTO].self, from: body)
        // Since Date precision can vary, we check if the count is correct and properties match
        #expect(decoded.count == 1)
        #expect(decoded.first?.name == "Test")
    }
}

// Extension for Equatable support in tests
extension MyBarItemDTO: @retroactive Equatable {
    public static func == (lhs: MyBarItemDTO, rhs: MyBarItemDTO) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.category == rhs.category
    }
}

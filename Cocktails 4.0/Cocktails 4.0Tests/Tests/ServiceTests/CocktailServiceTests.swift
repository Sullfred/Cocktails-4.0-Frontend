import Testing
import Foundation
@testable import Cocktails_4_0

@Suite("CocktailService Logical Tests")
struct CocktailServiceTests {
    let mockClient = MockAPIClient()
    let mockImageService = MockImageService()
    let service: CocktailService
    let baseURL = ServiceConfig.baseURL
    
    init() {
        self.service = CocktailService(imageService: mockImageService, apiClient: mockClient)
    }
    
    @Test("Fetch cocktails successfully maps DTOs to Models")
    func testFetchCocktailsSuccess() async throws {
        let url = baseURL.appending(path: Endpoints.cocktails)
        let dtos = [
            CocktailDTO(
                id: UUID(),
                name: "Martini",
                creator: "Classic",
                style: "shaken",
                comment: "Everlasting classic",
                cocktailCategory: CocktailCategory.spiritForward.rawValue,
                imageURL: "http://test.com/image.jpg",
                ingredients: []
            )
        ]
        
        mockClient.setResponse(dtos, for: url)
        
        let cocktails = try await service.fetchCocktails()
        
        #expect(cocktails.count == 1)
        #expect(cocktails.first?.name == "Martini")
        #expect(cocktails.first?.style == .shaken)
        #expect(cocktails.first?.cocktailCategory == .spiritForward)
    }
    
    @Test("Fetch cocktails handles API error")
    func testFetchCocktailsFailure() async throws {
        let url = baseURL.appending(path: Endpoints.cocktails)
        mockClient.setError(APIError.httpError(statusCode: 500, message: "Server Error"), for: url)
        
        await #expect(throws: APIError.self) {
            try await service.fetchCocktails()
        }
    }
    
    @Test("Create cocktail sends correct payload and uploads image")
    func testCreateCocktailFlow() async throws {
        let url = baseURL.appending(path: Endpoints.cocktails)
        let cocktail = Cocktail(name: "Test", creator: "Me", style: .stirred, ingredients: [], comment: "", image: nil, imageURL: nil, cocktailCategory: .other)
        let imageData = "fake-image".data(using: .utf8)!
        let payload = CocktailPayload(cocktail: CocktailDTO(from: cocktail), imageAction: .upload, imageData: imageData)
        
        try await service.createCocktail(payload)
        
        // Verify API call
        let apiCall = try #require(mockClient.calls.first)
        #expect(apiCall.method == "POST")
        #expect(apiCall.url == url)
        
        // Verify image upload call
        #expect(mockImageService.uploadedImages.count == 1)
        let imageCall = try #require(mockImageService.uploadedImages.first)
        #expect(imageCall.id == cocktail.id)
        #expect(imageCall.data == imageData)
    }
    
    @Test("Update cocktail handles image actions correctly")
    func testUpdateCocktailImageActions() async throws {
        let cocktail = Cocktail(name: "Test", creator: "Me", style: .stirred, ingredients: [], comment: "", image: nil, imageURL: nil, cocktailCategory: .other)
        let payload = CocktailPayload(cocktail: CocktailDTO(from: cocktail), imageAction: .delete, imageData: nil)
        
        try await service.updateCocktail(payload)
        
        // Verify API mutate called
        let apiCall = try #require(mockClient.calls.first)
        #expect(apiCall.method == "PUT")
        
        // Verify image deletion requested
        #expect(mockImageService.deletedImages.contains(cocktail.id))
    }
    
    @Test("Server connection check returns true on success")
    func testCheckServerConnectionSuccess() async {
        let url = baseURL.appending(path: Endpoints.cocktails)
        mockClient.setResponse(EmptyResponse(), for: url) // ping usually just checks status
        
        let isConnected = await service.checkServerConnection()
        #expect(isConnected == true)
    }
    
    @Test("Server connection check returns false on failure")
    func testCheckServerConnectionFailure() async {
        let url = baseURL.appending(path: Endpoints.cocktails)
        mockClient.setError(APIError.networkFailure(NSError(domain: "Offline", code: -1)), for: url)
        
        let isConnected = await service.checkServerConnection()
        #expect(isConnected == false)
    }
}

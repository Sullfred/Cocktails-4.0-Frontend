import Testing
import Foundation
@testable import Cocktails_4_0

@Suite("AdminService Logical Tests")
struct AdminServiceTests {
    let mockClient = MockAPIClient()
    let service: AdminService
    let baseURL = ServiceConfig.baseURL
    
    init() {
        self.service = AdminService(apiClient: mockClient)
    }
    
    @Test("Fetch users returns list of public user DTOs")
    func testFetchUsersSuccess() async throws {
        let url = baseURL.appending(path: Endpoints.user + "/fetchUsers")
        let users = [
            fetchPublicUserDTO(id: UUID(), username: "admin", role: .admin),
            fetchPublicUserDTO(id: UUID(), username: "user1", role: .guest)
        ]
        
        mockClient.setResponse(users, for: url)
        
        let result = try await service.fetchUsers()
        
        #expect(result.count == 2)
        #expect(result.first?.username == "admin")
        #expect(mockClient.calls.count == 1)
    }
    
    @Test("Update user role sends correct PUT request")
    func testUpdateUserRoleSendsCorrectData() async throws {
        let userId = UUID()
        let url = baseURL.appending(path: Endpoints.user + "/updateUserRole")
        
        try await service.updateUserRole(userId: userId, newRole: .creator)
        
        let call = try #require(mockClient.calls.first)
        #expect(call.method == "PUT")
        #expect(call.url == url)
        
        let body = try #require(call.body)
        let dto = try JSONDecoder().decode(UpdateUserRoleDTO.self, from: body)
        #expect(dto.id == userId)
        #expect(dto.role == .creator)
    }
    
    @Test("Delete multiple cocktails triggers individual DELETE requests")
    func testDeleteCocktailsTriggersMultipleCalls() async throws {
        let ids = ["id1", "id2", "id3"]
        
        try await service.deleteCocktail(cocktailIds: ids)
        
        #expect(mockClient.calls.count == ids.count)
        
        for (index, id) in ids.enumerated() {
            let call = mockClient.calls[index]
            #expect(call.method == "DELETE")
            #expect(call.url.absoluteString.contains(id))
        }
    }
    
    @Test("Check server connection returns true on success")
    func testCheckServerConnectionSuccess() async throws {
        let url = baseURL.appending(path: Endpoints.cocktails)
        mockClient.setResponse(EmptyResponse(), for: url)
        
        let connected = try await service.checkServerConnection()
        #expect(connected == true)
    }
    
    @Test("Check server connection returns false on API error")
    func testCheckServerConnectionFailure() async throws {
        let url = baseURL.appending(path: Endpoints.cocktails)
        mockClient.setError(APIError.httpError(statusCode: 503, message: "Service Unavailable"), for: url)
        
        let connected = try await service.checkServerConnection()
        #expect(connected == false)
    }
}

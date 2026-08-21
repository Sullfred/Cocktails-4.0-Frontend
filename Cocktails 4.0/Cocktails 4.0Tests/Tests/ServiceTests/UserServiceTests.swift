import Testing
import Foundation
@testable import Cocktails_4_0

@Suite("UserService Logical Tests")
struct UserServiceTests {
    let mockClient = MockAPIClient()
    let service: UserService
    let baseURL = ServiceConfig.baseURL
    
    init() {
        self.service = UserService(apiClient: mockClient)
    }
    
    @Test("Successful login returns token and user")
    func testLoginSuccess() async throws {
        let expectedToken = "test-jwt-token"
        let expectedUser = UserDTO(id: UUID(), username: "testuser", role: .guest)
        let response = LoginResponse(token: expectedToken, user: expectedUser)
        
        let url = baseURL.appending(path: Endpoints.user + "/login")
        mockClient.setResponse(response, for: url)
        
        let result = try await service.login(username: "testuser", password: "password123")
        
        #expect(result.token == expectedToken)
        #expect(result.user.username == "testuser")
        #expect(mockClient.calls.count == 1)
        
        let call = try #require(mockClient.calls.first)
        #expect(call.method == "POST")
        #expect(call.url == url)
    }
    
    @Test("Login failure throws APIError")
    func testLoginFailure() async throws {
        let url = baseURL.appending(path: Endpoints.user + "/login")
        let networkError = APIError.httpError(statusCode: 401, message: "Unauthorized")
        mockClient.setError(networkError, for: url)
        
        await #expect(throws: APIError.self) {
            try await service.login(username: "wrong", password: "wrong")
        }
    }
    
    @Test("Verify token success")
    func testVerifyTokenSuccess() async throws {
        let url = baseURL.appending(path: Endpoints.user + "/verifyToken")
        mockClient.setResponse(Data(), for: url)
        
        try await service.verifyToken("valid-token")
        
        let call = try #require(mockClient.calls.first)
        #expect(call.method == "GET")
        #expect(call.url == url)
    }
    
    @Test("Verify token failure throws error")
    func testVerifyTokenFailure() async throws {
        let url = baseURL.appending(path: Endpoints.user + "/verifyToken")
        mockClient.setError(APIError.httpError(statusCode: 401, message: "Expired"), for: url)
        
        await #expect(throws: APIError.self) {
            try await service.verifyToken("expired-token")
        }
    }
    
    @Test("Registration sends correct DTO")
    func testRegisterSendsCorrectData() async throws {
        let url = baseURL.appending(path: Endpoints.user + "/register")
        
        try await service.register(username: "newuser", password: "pass", confirmPassword: "pass")
        
        let call = try #require(mockClient.calls.first)
        #expect(call.method == "POST")
        #expect(call.url == url)
        
        let body = try #require(call.body)
        let dto = try JSONDecoder().decode(CreateUserDTO.self, from: body)
        #expect(dto.username == "newuser")
        #expect(dto.password == "pass")
    }
    
    @Test("Logout handles 401 as success")
    func testLogoutHandlesUnauthorizedAsSuccess() async throws {
        let url = baseURL.appending(path: Endpoints.user + "/logout")
        mockClient.setError(APIError.httpError(statusCode: 401, message: "Unauthorized"), for: url)
        
        // Should not throw
        try await service.logout()
        
        #expect(mockClient.calls.count == 1)
    }
    
    @Test("Logout throws on unexpected errors")
    func testLogoutThrowsOnServerError() async throws {
        let url = baseURL.appending(path: Endpoints.user + "/logout")
        mockClient.setError(APIError.httpError(statusCode: 500, message: "Internal Server Error"), for: url)
        
        await #expect(throws: APIError.self) {
            try await service.logout()
        }
    }
}

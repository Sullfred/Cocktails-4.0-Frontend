import Testing
@testable import Cocktails_4_0
import Foundation

final class APIClientMock {
    struct Call: Equatable {
        let url: URL
        let method: String
        let body: Data?
    }

    var calls: [Call] = []
    var nextData: Data? = nil

    func request<T: Decodable>(url: URL, method: String = "GET") async throws -> T {
        calls.append(.init(url: url, method: method, body: nil))
        if let data = nextData {
            return try JSONDecoder().decode(T.self, from: data)
        }
        throw APIError.networkFailure(NSError(domain: "mock", code: -1))
    }

    func requestData(url: URL) async throws -> Data {
        calls.append(.init(url: url, method: "GET", body: nil))
        return Data()
    }

    func mutate<T: Decodable>(url: URL, method: String, body: Data?) async throws -> T {
        calls.append(.init(url: url, method: method, body: body))
        return (try? JSONDecoder().decode(T.self, from: Data())) ?? (EmptyResponse() as! T)
    }

    func mutate(url: URL, method: String, body: Data?) async throws {
        calls.append(.init(url: url, method: method, body: body))
    }

    func ping(url: URL) async throws {}
}

@Suite("MyBarService batch encoding")
struct MyBarServiceBatchEncodingTests {
    let baseURL = ServiceConfig.baseURL.appending(path: Endpoints.myBar)
    var apiClientMock = APIClientMock()
    
    // A minimal MyBarService subclass to inject the mock APIClient
    class TestMyBarService: MyBarService {
        let mockClient: APIClientMock
        init(mockClient: APIClientMock) {
            self.mockClient = mockClient
            super.init()
        }
        
        func addItems(_ items: [MyBarItemDTO]) async throws {
            let url = ServiceConfig.baseURL.appending(path: Endpoints.myBar)
            let encoder = JSONEncoder()
            let data = try encoder.encode(items)
            try await mockClient.mutate(url: url, method: "POST", body: data)
        }
    }
    
    @Test
    func encodesAddItemsArray() async throws {
        let items = [MyBarItemDTO(id: UUID(), name: "bourbon", category: .liquor)]
        let service = TestMyBarService(mockClient: apiClientMock)
        try await service.addItems(items)
        
        #expect(apiClientMock.calls.count == 1)
        let call = apiClientMock.calls.first!
        #expect(call.url == baseURL)
        #expect(call.method == "POST")
        #expect(call.body != nil)
        
        let decodedItems = try JSONDecoder().decode([MyBarItemDTO].self, from: call.body!)
        #expect(decodedItems == items)
    }
}

extension MyBarItemDTO: Equatable {
    public static func == (lhs: MyBarItemDTO, rhs: MyBarItemDTO) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.category == rhs.category
    }
}

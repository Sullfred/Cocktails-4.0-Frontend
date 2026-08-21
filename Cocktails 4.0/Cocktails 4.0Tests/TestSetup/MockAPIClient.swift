import Foundation
@testable import Cocktails_4_0

final class MockAPIClient: APIClientProtocol {
    struct Call: Equatable {
        let url: URL
        let method: String
        let body: Data?
    }

    var calls: [Call] = []
    var responses: [URL: Any] = [:]
    var errorToThrow: Error?

    func setResponse<T>(_ response: T, for url: URL) {
        responses[url] = response
    }

    func setError(_ error: Error, for url: URL) {
        responses[url] = error
    }

    func request<T: Decodable>(url: URL, method: String, body: Data?, headers: [String: String]? = nil) async throws -> T {
        calls.append(Call(url: url, method: method, body: body))
        
        if let error = errorToThrow { throw error }
        if let error = responses[url] as? Error { throw error }
        
        guard let response = responses[url] as? T else {
            throw APIError.networkFailure(NSError(domain: "MockAPIClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "No response configured for \(url)"]))
        }
        return response
    }

    func requestData(url: URL, method: String, body: Data?, headers: [String: String]? = nil) async throws -> Data {
        calls.append(Call(url: url, method: method, body: body))
        
        if let error = errorToThrow { throw error }
        if let error = responses[url] as? Error { throw error }
        
        guard let response = responses[url] as? Data else {
            throw APIError.networkFailure(NSError(domain: "MockAPIClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data response configured for \(url)"]))
        }
        return response
    }

    func mutate<T: Decodable>(url: URL, method: String, body: Data?, responseType: T.Type) async throws -> T {
        calls.append(Call(url: url, method: method, body: body))
        
        if let error = errorToThrow { throw error }
        if let error = responses[url] as? Error { throw error }
        
        if T.self == EmptyResponse.self {
            return EmptyResponse() as! T
        }
        
        guard let response = responses[url] as? T else {
            throw APIError.networkFailure(NSError(domain: "MockAPIClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "No response configured for \(url)"]))
        }
        return response
    }

    func upload(url: URL, method: String, imageData: Data, fileName: String, mimeType: String) async throws -> EmptyResponse {
        calls.append(Call(url: url, method: method, body: imageData))
        if let error = errorToThrow { throw error }
        if let error = responses[url] as? Error { throw error }
        return EmptyResponse()
    }

    func delete(url: URL) async throws {
        calls.append(Call(url: url, method: "DELETE", body: nil))
        if let error = errorToThrow { throw error }
        if let error = responses[url] as? Error { throw error }
    }

    func ping(url: URL) async throws {
        calls.append(Call(url: url, method: "HEAD", body: nil))
        if let error = errorToThrow { throw error }
        if let error = responses[url] as? Error { throw error }
    }
}

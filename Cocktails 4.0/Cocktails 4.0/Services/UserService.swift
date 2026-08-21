//
//  UserAPI.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 26/09/2025.
//

import Foundation

final class UserService {
    private let base = ServiceConfig.baseURL
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func login(username: String, password: String) async throws -> LoginResponse {
        let url = base.appending(path: Endpoints.user + "/login")
        let creds = "\(username):\(password)"
        guard let loginData = creds.data(using: .utf8) else {
            throw APIError.networkFailure(NSError(domain: "Auth", code: -1))
        }
        let base64Creds = loginData.base64EncodedString()
        
        let headers = [
            "Authorization": "Basic \(base64Creds)",
            "Accept": "json"
        ]
        
        return try await apiClient.request(
            url: url,
            method: "POST",
            body: nil,
            headers: headers
        )
    }

    func verifyToken(_ token: String) async throws {
        let url = base.appending(path: Endpoints.user + "/verifyToken")
        let headers = ["Authorization": "Bearer \(token)"]
        
        // verifyToken just needs to check if it throws or not
        // We use requestData since we don't need to decode a specific type
        _ = try await apiClient.requestData(
            url: url,
            method: "GET",
            body: nil,
            headers: headers
        )
    }

    func register(username: String, password: String, confirmPassword: String) async throws {
        let url = base.appending(path: Endpoints.user + "/register")
        let body = try JSONEncoder().encode(CreateUserDTO(username: username, password: password, confirmPassword: confirmPassword))
        let _ = try await apiClient.mutate(
            url: url,
            method: "POST",
            body: body,
            responseType: EmptyResponse.self
        )
    }

    func updateUsername(_ newUsername: String) async throws {
        let url = base.appending(path: Endpoints.user + "/updateUsername")
        let body = try JSONEncoder().encode(UpdateUsernameDTO(newUsername: newUsername))
        let _ = try await apiClient.mutate(
            url: url,
            method: "PATCH",
            body: body,
            responseType: EmptyResponse.self
        )
    }

    func updatePassword(current: String, new: String, confirm: String) async throws {
        let url = base.appending(path: Endpoints.user + "/updatePassword")
        let body = try JSONEncoder().encode(UpdatePasswordDTO(currentPassword: current, newPassword: new, confirmNewPassword: confirm))
        let _ = try await apiClient.mutate(
            url: url,
            method: "PATCH",
            body: body,
            responseType: EmptyResponse.self
        )
    }

    func deleteUser() async throws {
        let url = base.appending(path: Endpoints.user + "/me")
        let _ = try await apiClient.mutate(
            url: url,
            method: "DELETE",
            body: nil,
            responseType: EmptyResponse.self
        )
    }

    func logout() async throws {
        let url = base.appending(path: Endpoints.user + "/logout")
        do {
            let _ = try await apiClient.mutate(url: url, method: "POST", body: nil, responseType: EmptyResponse.self)
        } catch APIError.httpError(let code, _) where [401, 403, 404].contains(code) {
            return // Already expired/invalid, treat as success
        } catch {
            throw error
        }
    }
}

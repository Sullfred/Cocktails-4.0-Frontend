//
//  UserAPI.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 26/09/2025.
//

import Foundation

final class UserService {
    private let base = ServiceConfig.baseURL

    func login(username: String, password: String) async throws -> LoginResponse {
        let url = base.appending(path: Endpoints.user + "/login")
        let creds = "\(username):\(password)"
        guard let loginData = creds.data(using: .utf8) else {
            throw APIError.networkFailure(NSError(domain: "Auth", code: -1))
        }
        let base64Creds = loginData.base64EncodedString()

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let apiKey = ServiceConfig.apiKey
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("Basic \(base64Creds)", forHTTPHeaderField: "Authorization")
        request.setValue("json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        try APIError.map(data, response, url: request.url?.absoluteString ?? "")

        return try JSONDecoder().decode(LoginResponse.self, from: data)
    }

    func verifyToken(_ token: String) async throws {
        let url = base.appending(path: Endpoints.user + "/verifyToken")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let apiKey = ServiceConfig.apiKey
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await URLSession.shared.data(for: request)
        try APIError.map(nil, response, url: "verifyToken")
    }

    func register(username: String, password: String, confirmPassword: String) async throws {
        let url = base.appending(path: Endpoints.user + "/register")
        let body = try JSONEncoder().encode(CreateUserDTO(username: username, password: password, confirmPassword: confirmPassword))
        try await APIClient.mutate(url: url, method: "POST", body: body)
    }

    func updateUsername(_ newUsername: String) async throws {
        let url = base.appending(path: Endpoints.user + "/updateUsername")
        let body = try JSONEncoder().encode(UpdateUsernameDTO(newUsername: newUsername))
        try await APIClient.mutate(url: url, method: "PATCH", body: body)
    }

    func updatePassword(current: String, new: String, confirm: String) async throws {
        let url = base.appending(path: Endpoints.user + "/updatePassword")
        let body = try JSONEncoder().encode(UpdatePasswordDTO(currentPassword: current, newPassword: new, confirmNewPassword: confirm))
        try await APIClient.mutate(url: url, method: "PATCH", body: body)
    }

    func deleteUser() async throws {
        let url = base.appending(path: Endpoints.user + "/me")
        try await APIClient.mutate(url: url, method: "DELETE")
    }

    func logout() async throws {
        let url = base.appending(path: Endpoints.user + "/logout")
        do {
            try await APIClient.mutate(url: url, method: "POST")
        } catch APIError.httpError(let code, _) where [401, 403, 404].contains(code) {
            return // Already expired/invalid, treat as success
        } catch {
            throw error
        }
    }
}

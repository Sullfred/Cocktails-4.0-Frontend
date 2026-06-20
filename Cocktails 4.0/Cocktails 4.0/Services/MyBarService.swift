//
//  MyBarAPI.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 26/09/2025.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
final class MyBarService {
    private let serviceURL = ServiceConfig.baseURL.appending(path: Endpoints.myBar)

    init() {}
    
    // Get the users personal bar
    func fetchMyBar() async throws -> MyBar {
        let url = serviceURL
        let myBarDTO: MyBarDTO = try await APIClient.request(url: url, method: "GET")

        let personalBar = MyBar(from: myBarDTO)

        return personalBar
    }
    
    func addBarItem(_ payload: MyBarItemDTO) async throws {
        let url = serviceURL.appending(path: "items")
        let body = try JSONEncoder().encode(payload)

        try await APIClient.mutate(
            url: url,
            method: "POST",
            body: body
        )
    }

    func deleteBarItem(_ payload: MyBarItemDTO) async throws {
        let url = serviceURL
            .appending(path: "items")
            .appending(path: payload.name)

        try await APIClient.mutate(
            url: url,
            method: "DELETE"
        )
    }

    func addFavorite(_ cocktailID: String) async throws {
        let url = serviceURL
            .appending(path: "favorites")
            .appending(path: cocktailID)

        try await APIClient.mutate(
            url: url,
            method: "POST"
        )
    }

    func deleteFavorite(_ cocktailID: String) async throws {
        let url = serviceURL
            .appending(path: "favorites")
            .appending(path: cocktailID)

        try await APIClient.mutate(
            url: url,
            method: "DELETE"
        )
    }

    func addRemoved(_ payload: RemovedCocktailDTO) async throws {
        let url = serviceURL.appending(path: "removed")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let body = try encoder.encode(payload)

        try await APIClient.mutate(
            url: url,
            method: "POST",
            body: body
        )
    }

    func deleteRemoved(_ payload: RemovedCocktailDTO) async throws {
        let url = serviceURL
            .appending(path: "removed")
            .appending(path: payload.id)

        try await APIClient.mutate(
            url: url,
            method: "DELETE"
        )
    }
}

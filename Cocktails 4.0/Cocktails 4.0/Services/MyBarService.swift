//
//  MyBarAPI.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 26/09/2025.
//

import Foundation
import SwiftData
import SwiftUI

class MyBarService {
    private let serviceURL = ServiceConfig.baseURL.appending(path: Endpoints.myBar)

    init() {}
    
    // Get the users personal bar
    func fetchMyBar() async throws -> MyBar {
        let url = serviceURL
        let myBarDTO: MyBarDTO = try await APIClient.request(url: url, method: "GET")

        let personalBar = MyBar(from: myBarDTO)

        return personalBar
    }
    
    func addBarItem(_ payloads: [MyBarItemDTO]) async throws {
        let url = serviceURL.appending(path: "items")
        let body = try JSONEncoder().encode(payloads)

        try await APIClient.mutate(url: url, method: "POST",body: body)
    }

    func deleteBarItems(_ payloads: [UUID]) async throws {
        let url = serviceURL.appending(path: "items")
        let dto = RemoveBarItemsDTO(itemIds: payloads.map { $0 })
        let body = try JSONEncoder().encode(dto)
        try await APIClient.mutate(url: url, method: "DELETE", body: body)
    }

    func addFavorites(_ cocktailIDs: [UUID]) async throws {
        let url = serviceURL.appending(path: "favorites")
        let dto = AddFavoritesDTO(itemIds: cocktailIDs)
        let body = try JSONEncoder().encode(dto)
        try await APIClient.mutate(url: url, method: "POST", body: body)
    }

    func deleteFavorites(_ cocktailIDs: [UUID]) async throws {
        let url = serviceURL.appending(path: "favorites")
        let dto = RemoveFavoritesDTO(itemIds: cocktailIDs)
        let body = try JSONEncoder().encode(dto)
        try await APIClient.mutate(url: url, method: "DELETE", body: body)
    }

    func addHiddenCocktail(_ payloads: [HiddenCocktailDTO]) async throws {
        let url = serviceURL.appending(path: "hiddenCocktail")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let body = try encoder.encode(payloads)

        try await APIClient.mutate(url: url, method: "POST",body: body)
    }

    func deleteRemoved(_ payloads: [UUID]) async throws {
        let url = serviceURL.appending(path: "hiddenCocktail")
        let dto = RemoveHiddenCocktailsDTO(itemIds: payloads.map { $0 })
        let body = try JSONEncoder().encode(dto)
        try await APIClient.mutate(url: url, method: "DELETE", body: body)
    }
}

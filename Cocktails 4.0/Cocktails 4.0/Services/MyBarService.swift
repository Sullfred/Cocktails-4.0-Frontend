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
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func fetchMyBar() async throws -> MyBar {
        let url = serviceURL
        let myBarDTO: MyBarDTO = try await apiClient.request(url: url, method: "GET", body: nil, headers: nil)
        return MyBar(from: myBarDTO)
    }
    
    func addBarItem(_ payloads: [MyBarItemDTO]) async throws {
        let url = serviceURL.appending(path: "items")
        let body = try JSONEncoder().encode(payloads)
        let _ = try await apiClient.mutate(
            url: url,
            method: "POST",
            body: body,
            responseType: EmptyResponse.self
        )
    }
    
    func deleteBarItems(_ payloads: [UUID]) async throws {
        let url = serviceURL.appending(path: "items")
        let dto = RemoveBarItemsDTO(itemIds: payloads.map { $0 })
        let body = try JSONEncoder().encode(dto)
        let _ = try await apiClient.mutate(
            url: url,
            method: "DELETE",
            body: body,
            responseType: EmptyResponse.self
        )
    }
    
    func addFavorites(_ cocktailIDs: [UUID]) async throws {
        let url = serviceURL.appending(path: "favorites")
        let dto = AddFavoritesDTO(itemIds: cocktailIDs)
        let body = try JSONEncoder().encode(dto)
        let _ = try await apiClient.mutate(
            url: url,
            method: "POST",
            body: body,
            responseType: EmptyResponse.self
        )
    }
    
    func deleteFavorites(_ cocktailIDs: [UUID]) async throws {
        let url = serviceURL.appending(path: "favorites")
        let dto = RemoveFavoritesDTO(itemIds: cocktailIDs)
        let body = try JSONEncoder().encode(dto)
        let _ = try await apiClient.mutate(
            url: url,
            method: "DELETE",
            body: body,
            responseType: EmptyResponse.self
        )
    }
    
    func addHiddenCocktail(_ payloads: [HiddenCocktailDTO]) async throws {
        let url = serviceURL.appending(path: "hiddenCocktail")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(payloads)
        let _ = try await apiClient.mutate(
            url: url,
            method: "POST",
            body: body,
            responseType: EmptyResponse.self
        )
    }
    
    func deleteRemoved(_ payloads: [UUID]) async throws {
        let url = serviceURL.appending(path: "hiddenCocktail")
        let dto = RemoveHiddenCocktailsDTO(itemIds: payloads.map { $0 })
        let body = try JSONEncoder().encode(dto)
        let _ = try await apiClient.mutate(
            url: url,
            method: "DELETE",
            body: body,
            responseType: EmptyResponse.self
        )
    }
}


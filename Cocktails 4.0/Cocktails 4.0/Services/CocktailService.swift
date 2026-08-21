//
//  CocktailService.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 27/08/2025.
//

import Foundation
import SwiftData
import SwiftUI

class CocktailService {
    private let serviceURL = ServiceConfig.baseURL.appending(path: Endpoints.cocktails)
    private let imageService: ImageService
    private let apiClient: APIClientProtocol

    init(imageService: ImageService, apiClient: APIClientProtocol) {
        self.imageService = imageService
        self.apiClient = apiClient
    }
    
    func fetchCocktails() async throws -> [Cocktail] {
        let cocktailDTOs: [CocktailDTO] = try await apiClient.request(url: serviceURL, method: "GET", body: nil, headers: nil)
        var cocktails: [Cocktail] = cocktailDTOs.map { Cocktail(from: $0) }
        cocktails = await hydrateImages(for: cocktails, with: cocktailDTOs)
        return cocktails
    }
    
    func createCocktail(_ payload: CocktailPayload) async throws {
        let body = try JSONEncoder().encode(payload.cocktail)
        let _: EmptyResponse = try await apiClient.mutate(
            url: serviceURL,
            method: "POST",
            body: body,
            responseType: EmptyResponse.self
        )
        
        if (payload.imageAction == .upload) {
            guard let imageData = payload.imageData else {
                throw PendingActionError.imageDecodingError
            }
            try await imageService.uploadImage(for: payload.cocktail.id, imageData: imageData)
        }
    }
    
    func updateCocktail(_ payload: CocktailPayload) async throws {
        let url = serviceURL.appending(path: payload.cocktail.id.uuidString)
        let body = try JSONEncoder().encode(payload.cocktail)
        let _ = try await apiClient.mutate(
            url: url,
            method: "PUT",
            body: body,
            responseType: EmptyResponse.self
        )
        
        switch (payload.imageAction) {
        case .update:
            guard let imageData = payload.imageData else {
                throw PendingActionError.imageDecodingError
            }
            try await imageService.updateImage(for: payload.cocktail.id, imageData: imageData)
        case .upload:
            guard let imageData = payload.imageData else {
                throw PendingActionError.imageDecodingError
            }
            try await imageService.uploadImage(for: payload.cocktail.id, imageData: imageData)
        case .delete:
            try await imageService.deleteImage(for: payload.cocktail.id)
        case .unchanged:
            break;
        }
    }
    
    func checkServerConnection() async -> Bool {
        let url = serviceURL
        do {
            try await apiClient.ping(url: url)
            return true
        } catch {
            return false
        }
    }
    
    private func hydrateImages(for cocktails: [Cocktail],with dtos: [CocktailDTO]) async -> [Cocktail] {
        let result = cocktails
        
        await withTaskGroup(of: HydratedImage.self) { group in
            for index in result.indices {
                let dto = dtos[index]
                group.addTask {
                    guard dto.imageURL != nil else {
                        return HydratedImage(
                            index: index,
                            image: ImageCacheHelper.loadCachedImage(for: dto.id),
                            imageURL: nil
                        )
                    }
                    do {
                        let data = try await self.imageService.fetchImage(for: dto.id)
                        return HydratedImage(
                            index: index,
                            image: data,
                            imageURL: dto.imageURL
                        )
                    } catch {
                        return HydratedImage(
                            index: index,
                            image: ImageCacheHelper.loadCachedImage(for: dto.id),
                            imageURL: nil
                        )
                    }
                }
            }
            for await hydratedImage in group {
                result[hydratedImage.index].image = hydratedImage.image
                result[hydratedImage.index].imageURL = hydratedImage.imageURL
            }
        }
        return result
    }
    
    private struct HydratedImage {
        let index: Int
        let image: Data?
        let imageURL: String?
    }
}

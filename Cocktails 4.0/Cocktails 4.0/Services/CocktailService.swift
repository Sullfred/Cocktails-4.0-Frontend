//
//  CocktailService.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 27/08/2025.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
final class CocktailService {
    private let serviceURL = ServiceConfig.baseURL.appending(path: Endpoints.cocktails)
    private let imageService: ImageService
    
    init(imageService: ImageService) {
        self.imageService = imageService
    }
    
    // Fetches cocktails from the server, prepares their images, and returns `[Cocktail]`.
    func fetchCocktails() async throws -> [Cocktail] {
        var cocktailDTOs: [CocktailDTO] = try await APIClient.request(url: serviceURL)
        var cocktails: [Cocktail] = cocktailDTOs.map { Cocktail(from: $0) }
        
        // Get cocktail images
        cocktails = await hydrateImages(for: cocktails, with: cocktailDTOs)
        
        return cocktails
    }
    
    func createCocktail(_ payload: CocktailPayload) async throws {
        let body = try JSONEncoder().encode(payload.cocktail)
        let _: EmptyResponse = try await APIClient.mutate(
            url: serviceURL,
            method: "POST",
            body: body
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
        
        // 1. Update cocktail
        let body = try JSONEncoder().encode(payload.cocktail)
        try await APIClient.mutate(
            url: url,
            method: "PUT",
            body: body
        )
        
        // 2. Handle image update/upload/deletion
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
    
    // Check if the server is reachable by sending a HEAD request to the cocktails endpoint
    func checkServerConnection() async -> Bool {
        let url = serviceURL
        
        do {
            try await APIClient.ping(url: url)
            return true
        } catch {
            return false
        }
    }
    
    // Helper function for handling images after fetching a cocktail
    private func hydrateImages(for cocktails: [Cocktail], with dtos: [CocktailDTO]) async -> [Cocktail] {
        var result: [Cocktail] = cocktails
        
        for index in result.indices {
            let dto = dtos[index]
            
            // Skip if no image exists remotely
            guard dto.imageURL != nil else {
                result[index].image = ImageCacheHelper.loadCachedImage(for: dto.id)
                result[index].imageURL = nil
                
                continue
            }
            
            do {
                let data = try await imageService.fetchImage(for: dto.id)
                
                result[index].image = data
                result[index].imageURL = dto.imageURL
            } catch {
                // fallback to cache only (no UI side effects in service layer)
                result[index].image = ImageCacheHelper.loadCachedImage(for: dto.id)
                result[index].imageURL = nil
            }
        }
        
        return result
    }
}

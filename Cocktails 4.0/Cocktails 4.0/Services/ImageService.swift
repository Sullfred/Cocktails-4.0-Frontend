//
//  ImageService.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 14/06/2026.
//

import Foundation

class ImageService {
    private let serviceURL = ServiceConfig.baseURL.appending(path: Endpoints.image)
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func uploadImage(for cocktailID: UUID, imageData: Data) async throws {
        let imageURL = serviceURL.appending(path: "\(cocktailID)/image")
        let _ = try await apiClient.upload(
            url: imageURL,
            method: "POST",
            imageData: imageData,
            fileName: "\(cocktailID).jpg",
            mimeType: "image/jpeg",
        )
    }
    
    func updateImage(for cocktailID: UUID, imageData: Data) async throws {
        let imageURL = serviceURL.appending(path: "\(cocktailID)/image")
        let _ = try await apiClient.upload(
            url: imageURL,
            method: "PUT",
            imageData: imageData,
            fileName: "\(cocktailID).jpg",
            mimeType: "image/jpeg",
        )
        ImageCacheHelper.cacheImage(imageData,for: cocktailID)
    }
    
    func deleteImage(for cocktailID: UUID) async throws {
        let imageURL = serviceURL.appending(path: "\(cocktailID)/image")
        try await apiClient.delete(url: imageURL)
        ImageCacheHelper.removeCachedImage(for: cocktailID)
    }
    
    func fetchImage(for cocktailID: UUID) async throws -> Data {
        let imageURL = serviceURL.appending(path: "\(cocktailID)/image")
        let data: Data = try await apiClient.requestData(url: imageURL, method: "GET", body: nil, headers: nil)
        ImageCacheHelper.cacheImage(data, for: cocktailID)
        return data
    }
}


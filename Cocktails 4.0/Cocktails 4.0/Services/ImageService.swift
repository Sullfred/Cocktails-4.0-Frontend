//
//  ImageService.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 14/06/2026.
//

import Foundation

final class ImageService {
    private let serviceURL = ServiceConfig.baseURL.appending(path: Endpoints.image)
    
    init() {}
    
    func uploadImage(for cocktailID: UUID, imageData: Data) async throws {
        let imageURL = serviceURL.appending(path: "\(cocktailID)/image")

        try await APIClient.upload(
            url: imageURL,
            method: "POST",
            imageData: imageData,
            fileName: "\(cocktailID).jpg"
        )
    }
    
    func updateImage(for cocktailID: UUID, imageData: Data) async throws {
        let imageURL = serviceURL.appending(path: "\(cocktailID)/image")

        try await APIClient.upload(
            url: imageURL,
            method: "PUT",
            imageData: imageData,
            fileName: "\(cocktailID).jpg"
        )

        ImageCacheHelper.cacheImage(imageData,for: cocktailID)
    }
    
    func deleteImage(for cocktailID: UUID) async throws {
        let imageURL = serviceURL.appending(path: "\(cocktailID)/image")

        try await APIClient.delete(url: imageURL)

        ImageCacheHelper.removeCachedImage(for: cocktailID)
    }
    
    func fetchImage(for cocktailID: UUID) async throws -> Data {
        let imageURL = serviceURL.appending(path: "\(cocktailID)/image")

        let data: Data = try await APIClient.requestData(url: imageURL)

        ImageCacheHelper.cacheImage(data, for: cocktailID)

        return data
    }
    
}

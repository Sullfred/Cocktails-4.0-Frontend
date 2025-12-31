//
//  CocktailService.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 27/08/2025.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Image Cache Helpers
// Returns the file URL for the cached image for a given cocktail UUID in the app's caches directory.
private func cachedImageURL(for id: UUID) -> URL? {
    let fileManager = FileManager.default
    guard let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
        return nil
    }
    return caches.appendingPathComponent("cocktail_image_\(id.uuidString).jpg")
}

// Caches image data to disk for the given cocktail id. Returns the file URL if successful.
func cacheImage(_ data: Data, for id: UUID) -> URL? {
    guard let url = cachedImageURL(for: id) else { return nil }
    do {
        try data.write(to: url, options: .atomic)
        return url
    } catch {
        print("Failed to cache image for cocktail \(id): \(error)")
        return nil
    }
}

// Loads cached image data from disk for the given cocktail id, or nil if not present.
func loadCachedImage(for id: UUID) -> Data? {
    guard let url = cachedImageURL(for: id) else { return nil }
    return try? Data(contentsOf: url)
}

// Removes the cached image for the given cocktail id, if it exists.
func removeCachedImage(for id: UUID) {
    guard let url = cachedImageURL(for: id) else { return }
    try? FileManager.default.removeItem(at: url)
}


// MARK: - Server Communication
@MainActor
class CocktailService: ObservableObject {
    private let baseURL = ServiceConfig.baseURL // For handling imageURL
    private let serviceURL = ServiceConfig.baseURL.appending(path: Endpoints.cocktails)
    private let pendingActionService: PendingActionService
    
    init(context: ModelContext) {
        self.pendingActionService = PendingActionService(context: context)
    }
    
    // Fetches cocktails from the server, prepares their images, and returns `[Cocktail]`.
    func fetchCocktails() async throws -> [Cocktail] {
        let url = serviceURL
        
        var cocktails: [Cocktail] = []
        var cocktailDTOs: [CocktailDTO] = []
        
        // Request header
        var request = createRequestHeader(url: url, method: "GET")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
            throw error
        }
        
        // Decode response
        do {
            cocktailDTOs = try JSONDecoder().decode([CocktailDTO].self, from: data)
        } catch {
            print("Failed to decode cocktails: \(error)")
            throw error
        }
        
        // Prepare cocktails and images
        for dto in cocktailDTOs {
            var cocktail = Cocktail(from: dto)
            
            // If cocktail has an imageURL we get the image from the server
            if dto.imageURL != nil {
                let imageURL = serviceURL.appending(path: "\(dto.id)/image")
                let imageRequest = createRequestHeader(url: url, method: "GET")
                do {
                    let (imageData, imageResponse) = try await URLSession.shared.data(for: imageRequest)
                    if let error = ErrorHandler.mapHTTPResponse(imageResponse, data: imageData) {
                        print("Image HTTP error for \(cocktail.name): \(error)")
                        if let cachedImage = loadCachedImage(for: dto.id) {
                            cocktail.image = cachedImage
                            cocktail.imageURL = nil
                        }
                    } else {
                        cocktail.image = imageData
                        cocktail.imageURL = dto.imageURL
                        _ = cacheImage(imageData, for: dto.id)
                    }
                } catch {
                    ToastManager.shared.show(style: .warning, message: "Failed to get image for cocktail: \(cocktail.name)")
                    
                    print("Failed to download image for cocktail \(cocktail.name): \(error)")
                    // Try loading cached image if available
                    if let cachedImage = loadCachedImage(for: dto.id) {
                        cocktail.image = cachedImage
                        cocktail.imageURL = nil
                    }
                }
            } else {
                // No imageURL from server, try to load from cache if it exists
                if let cachedImage = loadCachedImage(for: dto.id) {
                    cocktail.image = cachedImage
                    cocktail.imageURL = nil
                } else {
                    cocktail.image = nil
                    cocktail.imageURL = nil
                }
            }
            cocktails.append(cocktail)
        }
        
        return cocktails
    }
    
    func addNewCocktail(userToken: String) async throws {
        let actions = try pendingActionService.fetchActions(ofType: .addCocktail)
        
        for action in actions {
            guard let cocktailDTO = action.decodePayload(as: CocktailDTO.self) else {
                print("Failed to decode payload for addCocktail action")
                continue
            }
            let url = serviceURL
            
            // Request header
            var request = createRequestHeader(url: url, method: "POST", token: userToken, setApplicationField: true)

            // Request body
            request.httpBody = try JSONEncoder().encode(cocktailDTO)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
                throw error
            }
            
            // Upload image if imageData is provided
            if let imageData = action.imageData {
                try await uploadImage(for: cocktailDTO.id, imageData: imageData, userToken: userToken)
            }
            
            try pendingActionService.remove(action)
        }
    }
    
    func updateCocktail(userToken: String) async throws {
        let actions = try pendingActionService.fetchActions(ofType: .updateCocktail)
        let deleteImageActions = try pendingActionService.fetchActions(ofType: .deleteCocktailImage)
        
        for action in actions {
            guard let cocktailDTO = action.decodePayload(as: CocktailDTO.self) else {
                print("Failed to decode payload for updateCocktail action")
                continue
            }
            let id = cocktailDTO.id
            let url = serviceURL.appending(path: "\(id.uuidString)")
            
            // Request header
            var request = createRequestHeader(url: url, method: "PUT", token: userToken, setApplicationField: true)
            
            // Request body
            request.httpBody = try JSONEncoder().encode(cocktailDTO)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
                // If 404, the cocktail was deleted on server
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 404 {
                    // Optionally handle local cleanup here if context is available
                    try pendingActionService.remove(action)
                } else {
                    throw error
                }
                continue
            }
            
            // After successful PUT, handle image upload or deletion
            if let imageData = action.imageData {
                try await updateImage(for: cocktailDTO.id, imageData: imageData, userToken: userToken)
            }
            try pendingActionService.remove(action)
        }
        
        // Go through deleteImageActions to delete images on the server
        for action in deleteImageActions {
            guard let cocktailId = action.decodePayload(as: UUID.self) else {
                print("Failed to decode payload for deleteCocktailImage action")
                continue
            }
            try await deleteImage(for: cocktailId, userToken: userToken)
            try pendingActionService.remove(action)
        }
    }
    
    // Function to delete image on the server and remove cached image
    func deleteImage(for cocktailID: UUID, userToken: String) async throws {
        let deleteImageURL = serviceURL.appending(path: "\(cocktailID)/image")
        
        // Request header
        var request = createRequestHeader(url: deleteImageURL, method: "DELETE", token: userToken)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
            print("Failed to delete image for cocktail \(cocktailID) on server: \(error)")
            throw error
        }
        // Remove cached image from disk
        removeCachedImage(for: cocktailID)
    }

    // Function for image Upload
    func uploadImage(for cocktailID: UUID, imageData: Data, userToken: String) async throws {
        let imageURL = serviceURL.appending(path: "\(cocktailID)/image")
        
        // Request header
        var request = createRequestHeader(url: imageURL, method: "POST", token: userToken)
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(cocktailID).jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
            print("Failed to upload image for cocktail \(cocktailID): \(error)")
        }
    }
    
    func updateImage(for cocktailID: UUID, imageData: Data, userToken: String) async throws {
        let imageURL = serviceURL.appending(path: "\(cocktailID)/image")
        
        // Request header
        var request = createRequestHeader(url: imageURL, method: "PUT", token: userToken)
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(cocktailID).jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
            print("Failed to update image for cocktail \(cocktailID): \(error)")
            throw error
        }
        
        // Cache new image locally after successful upload
        //_ = cacheImage(imageData, for: cocktailID)
    }
    
    // Check if the server is reachable by sending a HEAD request to the cocktails endpoint
    func checkServerConnection() async -> Bool {
        let url = serviceURL
        
        var request = createRequestHeader(url: url, method: "HEAD")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                return (200...299).contains(httpResponse.statusCode)
            }
        } catch {
            ErrorHandler.handle(error)
        }
        return false
    }
    
}

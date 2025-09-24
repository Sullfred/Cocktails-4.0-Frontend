//
//  CocktailAPI.swift
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
class CocktailAPI: ObservableObject {
    static let shared = CocktailAPI()
    private let baseURL = URL(string: "http://127.0.0.1:8080")!
    
    @Published private var pendingUploads: [Cocktail] = []
    @Published private var pendingDeletes: [Cocktail] = []
    @Published private var pendingUpdates: [Cocktail] = []
    
    private init() {}
    
    // MARK: - Cocktails
    // Functions to add cocktails to pending list
    func createCocktail(_ cocktail: Cocktail) async {
        pendingUploads.append(cocktail)
    }
    
    func deleteCocktail(_ cocktail: Cocktail) async {
        pendingDeletes.append(cocktail)
    }
    
    func updateCocktail(_ cocktail: Cocktail) async {
        pendingUpdates.append(cocktail)
    }
    
    func fetchCocktails(context: ModelContext) async {
        let url = baseURL.appendingPathComponent("cocktails")
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let cocktailDTOs = try JSONDecoder().decode([CocktailDTO].self, from: data)
            
            // Remove local cocktails not present on server
            let descriptor = FetchDescriptor<Cocktail>()
            let existingCocktails = try context.fetch(descriptor)
            let dtoIDs = Set(cocktailDTOs.map { $0.id })
            
            let myBarDescriptor = FetchDescriptor<MyBar>()
            let myBar = try? context.fetch(myBarDescriptor).first
            
            // Check for MyBar before clean up as deletedCocktailIDs is needed later
            let deletedCocktailIDs = Set(myBar?.deletedCocktails.map { $0.id } ?? [])
            
            // Clean up myBar: remove any with id not in dtoIDs
            if let myBar = myBar {
                let dtoIDs = Set(cocktailDTOs.map { $0.id })
                let filteredDeleted = myBar.deletedCocktails.filter { dtoIDs.contains(UUID(uuidString: $0.id) ?? UUID()) }
                myBar.deletedCocktails = filteredDeleted
                let filteredFavorites = myBar.favoriteCocktails.filter { dtoIDs.contains(UUID(uuidString: $0) ?? UUID()) }
                myBar.favoriteCocktails = filteredFavorites
            }
            
            // Remove cocktails which do not exist in the remote database
            var removedCocktails: [String] = []
            for cocktail in existingCocktails {
                if !dtoIDs.contains(cocktail.id) {
                    removedCocktails.append(cocktail.name.capitalized)
                    context.delete(cocktail)
                }
            }
            
            // Inform user about deleted cocktails
            if !removedCocktails.isEmpty {
                ToastManager.shared.show(style: .info, message: "Cocktails removed: \(removedCocktails.joined(separator: ", "))")
            }
            
            var addedCocktails: [String] = []
            for dto in cocktailDTOs {
                // Check if the cocktail is deleted locally - if true just continue
                if deletedCocktailIDs.contains(dto.id.uuidString) {
                    continue
                }
                
                if let existingCocktail = existingCocktails.first(where: { $0.id == dto.id }) {
                    // Update existing cocktail
                    existingCocktail.name = dto.name
                    existingCocktail.creator = dto.creator
                    existingCocktail.style = Style(rawValue: dto.style) ?? .shaken
                    existingCocktail.comment = dto.comment
                    existingCocktail.cocktailCategory = CocktailCategory(rawValue: dto.cocktailCategory) ?? .other
                    
                    existingCocktail.ingredients.removeAll()
                    for ingredientDTO in dto.ingredients {
                        let ingredient = Ingredient(from: ingredientDTO)
                        existingCocktail.ingredients.append(ingredient)
                        context.insert(ingredient)
                    }
                    
                    // Handle image from DTO
                    if let imageURLString = dto.imageURL {
                        if existingCocktail.imageURL != imageURLString {
                            // Determine if imageURLString is absolute or relative
                            let url: URL?
                            if imageURLString.hasPrefix("http://") || imageURLString.hasPrefix("https://") {
                                url = URL(string: imageURLString)
                            } else if imageURLString.hasPrefix("/Images/") {
                                url = baseURL.appendingPathComponent(String(imageURLString.dropFirst()))
                            } else {
                                url = URL(string: imageURLString)
                            }
                            if let url = url {
                                do {
                                    let (imageData, _) = try await URLSession.shared.data(from: url)
                                    existingCocktail.image = imageData
                                    existingCocktail.imageURL = imageURLString
                                    _ = cacheImage(imageData, for: dto.id)
                                } catch {
                                    print("Failed to download image for cocktail \(existingCocktail.name): \(error)")
                                }
                            }
                        }
                    } else {
                        // No imageURL from server, try to load from cache if it exists
                        if let cachedImage = loadCachedImage(for: dto.id) {
                            existingCocktail.image = cachedImage
                            existingCocktail.imageURL = nil
                        } else {
                            existingCocktail.image = nil
                            existingCocktail.imageURL = nil
                        }
                    }
                } else {
                    // Insert new cocktail
                    let cocktail = Cocktail(from: dto)
                    addedCocktails.append(cocktail.name.capitalized)
                    context.insert(cocktail)
                    
                    // Handle image from DTO
                    if let imageURLString = dto.imageURL {
                        // Determine if imageURLString is absolute or relative
                        let url: URL?
                        if imageURLString.hasPrefix("http://") || imageURLString.hasPrefix("https://") {
                            url = URL(string: imageURLString)
                        } else if imageURLString.hasPrefix("/Images/") {
                            url = baseURL.appendingPathComponent(String(imageURLString.dropFirst()))
                        } else {
                            url = URL(string: imageURLString)
                        }
                        if let url = url {
                            do {
                                let (imageData, _) = try await URLSession.shared.data(from: url)
                                cocktail.image = imageData
                                cocktail.imageURL = imageURLString
                                _ = cacheImage(imageData, for: dto.id)
                            } catch {
                                print("Failed to download image for cocktail \(cocktail.name): \(error)")
                            }
                        }
                    } else {
                        // No imageURL from server, try to load from cache
                        if let cachedImage = loadCachedImage(for: dto.id) {
                            cocktail.image = cachedImage
                            cocktail.imageURL = nil
                        } else {
                            cocktail.image = nil
                            cocktail.imageURL = nil
                        }
                    }
                }
            }
            try? context.save()
            
            if !addedCocktails.isEmpty {
                ToastManager.shared.show(style: .info, message: "Cocktails added: \(addedCocktails.joined(separator: ", "))")
            }
        } catch {
            print("Failed to fetch cocktails: \(error)")
        }
    }
    
    func syncPendingUploads(context: ModelContext) async {
        // Go through all the pending uploads
        for cocktail in pendingUploads {
            do {
                // Upload cocktail
                let cocktailDTO = CocktailDTO(from: cocktail)
                let url = baseURL.appendingPathComponent("cocktails")
                var request = URLRequest(url: url)
                
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONEncoder().encode(cocktailDTO)
                
                let (_, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    print("Failed to upload cocktail \(cocktail.name)")
                    continue
                }
                
                // Upload image if exists
                if let imageData = cocktail.image {
                    let imageURL = baseURL.appendingPathComponent("cocktails/\(cocktail.id)/image")
                    var imageRequest = URLRequest(url: imageURL)
                    imageRequest.httpMethod = "POST"
                    
                    let boundary = UUID().uuidString
                    imageRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                    
                    var body = Data()
                    body.append("--\(boundary)\r\n".data(using: .utf8)!)
                    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(cocktail.id).jpg\"\r\n".data(using: .utf8)!)
                    body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                    body.append(imageData)
                    body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
                    
                    imageRequest.httpBody = body
                    
                    let (_, imgResponse) = try await URLSession.shared.data(for: imageRequest)
                    if let httpResponse = imgResponse as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                        print("Failed to upload image for cocktail \(cocktail.name)")
                    }
                }
                
                // Remove from pending if success
                if let index = pendingUploads.firstIndex(where: { $0.id == cocktail.id }) {
                    pendingUploads.remove(at: index)
                }
                
            } catch {
                print("Failed to upload cocktail \(cocktail.name): \(error)")
            }
        }
    }
    
    func syncPendingDeletes() async {
        for cocktail in pendingDeletes {
            let id = cocktail.id
            let url = baseURL.appendingPathComponent("cocktails/\(id.uuidString)")
            var request = URLRequest(url: url)
            
            request.httpMethod = "DELETE"
            
            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                    print("Successfully deleted cocktail \(cocktail.name) on server.")
                    
                    if let index = pendingDeletes.firstIndex(where: { $0.id == cocktail.id }) {
                        pendingDeletes.remove(at: index)
                    }
                } else {
                    print("Failed to delete cocktail \(cocktail.name) on server: Invalid response.")
                }
            } catch {
                print("Failed to delete cocktail \(cocktail.name) on server: \(error)")
            }
        }
    }
    
    func syncPendingUpdates(context: ModelContext) async {
        // Go through all the pending updates
        for cocktail in pendingUpdates {
            
            do {
                let id = cocktail.id
                let cocktailDTO = CocktailDTO(from: cocktail)
                let url = baseURL.appendingPathComponent("cocktails/\(id.uuidString)")
                
                var request = URLRequest(url: url)
                
                request.httpMethod = "PUT"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONEncoder().encode(cocktailDTO)
                
                let (_, response) = try await URLSession.shared.data(for: request)
                if let httpResponse = response as? HTTPURLResponse {
                    if (200...299).contains(httpResponse.statusCode) {
                        
                        // After successful PUT, handle image upload or deletion
                        if let imageData = cocktail.image {
                            // Upload image
                            let imageURL = baseURL.appendingPathComponent("cocktails/\(cocktail.id)/image")
                            var imageRequest = URLRequest(url: imageURL)
                            imageRequest.httpMethod = "POST"
                            
                            let boundary = UUID().uuidString
                            imageRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                            
                            var body = Data()
                            body.append("--\(boundary)\r\n".data(using: .utf8)!)
                            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(cocktail.id).jpg\"\r\n".data(using: .utf8)!)
                            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                            body.append(imageData)
                            body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
                            
                            imageRequest.httpBody = body
                            
                            do {
                                let (_, imgResponse) = try await URLSession.shared.data(for: imageRequest)
                                if let imgHttpResponse = imgResponse as? HTTPURLResponse, !(200...299).contains(imgHttpResponse.statusCode) {
                                    print("Failed to upload image for cocktail \(cocktail.name)")
                                }
                                // Cache the image after upload
                                _ = cacheImage(imageData, for: cocktail.id)
                            } catch {
                                print("Failed to upload image for cocktail \(cocktail.name): \(error)")
                            }
                        } else {
                            // If image is nil but previously had an image, delete the image on the server and clear local image and imageURL
                            if cocktail.imageURL != nil {
                                let deleteImageURL = baseURL.appendingPathComponent("cocktails/\(cocktail.id)/image")
                                var deleteRequest = URLRequest(url: deleteImageURL)
                                deleteRequest.httpMethod = "DELETE"
                                
                                do {
                                    let (_, deleteResponse) = try await URLSession.shared.data(for: deleteRequest)
                                    if let deleteHttpResponse = deleteResponse as? HTTPURLResponse, (200...299).contains(deleteHttpResponse.statusCode) {
                                        cocktail.image = nil
                                        cocktail.imageURL = nil
                                        // Remove cached image from disk
                                        removeCachedImage(for: cocktail.id)
                                    } else {
                                        print("Failed to delete image for cocktail \(cocktail.name) on server")
                                    }
                                } catch {
                                    print("Failed to delete image for cocktail \(cocktail.name) on server: \(error)")
                                }
                            }
                        }
                        
                        // Remove from pending if success
                        if let index = pendingUpdates.firstIndex(where: { $0.id == cocktail.id }) {
                            pendingUpdates.remove(at: index)
                        }
                    } else if httpResponse.statusCode == 404 {
                        // Cocktail was deleted on server
                        // Clean up myBar
                        let myBarDescriptor = FetchDescriptor<MyBar>()
                        if let myBar = try? context.fetch(myBarDescriptor).first {
                            let deletedCocktailIDs = Set(myBar.deletedCocktails.map { $0.id })
                            let favoriteCocktailIDs = Set(myBar.favoriteCocktails)
                            
                            if favoriteCocktailIDs.contains(id.uuidString) {
                                let filteredFavorites = myBar.favoriteCocktails.filter { $0 != id.uuidString }
                                myBar.favoriteCocktails = filteredFavorites
                            }
                            
                            // If cocktail already has been deleted locally we remove it from deletedCocktails
                            // Else we remove it from the context
                            if deletedCocktailIDs.contains(id.uuidString) {
                                let filteredDeleted = myBar.deletedCocktails.filter { $0.id != id.uuidString }
                                myBar.deletedCocktails = filteredDeleted
                            } else {
                                let cocktailDescriptor = FetchDescriptor<Cocktail>(predicate: #Predicate {$0.id == id} )
                                if let localCocktail = try? context.fetch(cocktailDescriptor).first {
                                    context.delete(localCocktail)
                                }
                                //let cocktailDescriptor = FetchDescriptor<Cocktail>
                                // if let localCocktail = try? context.fetch(cocktailDescriptor).first(where: { $0.id == id }) {
                                //    context.delete(localCocktail)
                                //}
                            }
                            try? context.save()
                        }

                        // Remove from pending if success
                        if let index = pendingUpdates.firstIndex(where: { $0.id == cocktail.id }) {
                            pendingUpdates.remove(at: index)
                        }
                    }
                }
            } catch {
                print("Failed to update cocktail \(cocktail.name): \(error)")
            }
        }
    }
    
    // Check if the server is reachable by sending a HEAD request to the cocktails endpoint
    func checkServerConnection() async -> Bool {
        let url = baseURL.appendingPathComponent("cocktails")
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                return (200...299).contains(httpResponse.statusCode)
            }
        } catch {
            ToastManager.shared.show(style: .error, message: "No server connection!")
        }
        return false
    }
    
    
    // MARK: - Users
    func createUser(username: String, password: String, confirmPassword: String) async throws {
        let dto = CreateUserDTO(username: username, password: password, confirmPassword: confirmPassword)
        let url = baseURL.appendingPathComponent("users/register")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(dto)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "CocktailAPI", code: 1, userInfo: [NSLocalizedDescriptionKey: "No response from server"])
        }
        if !(200...299).contains(httpResponse.statusCode) {
            // Try to decode Vapor's Abort error message
            var errorMessage: String = "Failed to register user"
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let reason = json["reason"] as? String {
                errorMessage = reason
            } else if let string = String(data: data, encoding: .utf8), !string.isEmpty {
                errorMessage = string
            }
            throw NSError(domain: "CocktailAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
    }
    
    func login(username: String, password: String) async throws -> LoginResponse {
        let url = baseURL.appendingPathComponent("users/login")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Encode username and password in Basic Auth header
        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: .utf8) else {
            throw NSError(domain: "CocktailAPI", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode credentials"])
        }
        let base64Login = loginData.base64EncodedString()
        request.setValue("Basic \(base64Login)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "CocktailAPI", code: 1, userInfo: [NSLocalizedDescriptionKey: "No response from server"])
        }
        // Decode abort message for showing errors
        if !(200...299).contains(httpResponse.statusCode) {
            var errorMessage: String = "Failed to login"
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let reason = json["reason"] as? String {
                errorMessage = reason
            } else if let string = String(data: data, encoding: .utf8), !string.isEmpty {
                errorMessage = string
            }
            throw NSError(domain: "CocktailAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
        let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        return loginResponse
    }
}

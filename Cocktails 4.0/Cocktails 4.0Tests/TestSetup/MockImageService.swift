//
//  MockImageService.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 17/08/2026.
//

@testable import Cocktails_4_0
import Foundation

final class MockImageService: ImageService {
    struct Upload {
        let id: UUID
        let data: Data
    }
    var uploadedImages: [Upload] = []
    var deletedImages: [UUID] = []
    
    override init(apiClient: APIClientProtocol = MockAPIClient()) {
        super.init(apiClient: apiClient)
    }
    
    override func uploadImage(for cocktailID: UUID, imageData: Data) async throws {
        uploadedImages.append(Upload(id: cocktailID, data: imageData))
    }
    
    override func updateImage(for cocktailID: UUID, imageData: Data) async throws {
        uploadedImages.append(Upload(id: cocktailID, data: imageData))
    }
    
    override func deleteImage(for cocktailID: UUID) async throws {
        deletedImages.append(cocktailID)
    }
    
    override func fetchImage(for cocktailID: UUID) async throws -> Data {
        return "fake-image-data".data(using: .utf8)!
    }
}

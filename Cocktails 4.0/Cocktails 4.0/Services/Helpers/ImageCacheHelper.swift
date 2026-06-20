//
//  CacheImage.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 14/06/2026.
//

import Foundation

enum ImageCacheHelper {
    // Caches image data to disk for the given cocktail id. Returns the file URL if successful.
    static func cacheImage(_ data: Data, for id: UUID) {
        guard let url = cachedImageURL(for: id) else {
            return
        }
        try? data.write(to: url, options: .atomic)
    }
    
    // Loads cached image data from disk for the given cocktail id, or nil if not present.
    static func loadCachedImage(for id: UUID) -> Data? {
        guard let url = cachedImageURL(for: id) else {
            return nil
        }
        
        return try? Data(contentsOf: url)
    }

    // Removes the cached image for the given cocktail id, if it exists.
    static func removeCachedImage(for id: UUID) {
        guard let url = cachedImageURL(for: id) else {
            return
        }
        
        try? FileManager.default.removeItem(at: url)
    }
    
    // Returns the file URL for the cached image for a given cocktail UUID in the app's caches directory.
    private static func cachedImageURL(for id: UUID) -> URL? {
        let fileManager = FileManager.default
        guard let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        return caches.appendingPathComponent("cocktail_image_\(id.uuidString).jpg")
    }
}

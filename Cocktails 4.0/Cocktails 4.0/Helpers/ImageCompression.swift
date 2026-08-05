//
//  ImageCompression.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 04/08/2026.
//

import Foundation
import SwiftUI

func compressImageIfNeeded(_ data: Data) -> Data {
    let maxSize = 3 * 1024 * 1024 // 3 MB

    guard data.count > maxSize,
          let image = UIImage(data: data) else {
        return data
    }

    var compressionQuality: CGFloat = 0.9
    var compressedData = image.jpegData(compressionQuality: compressionQuality)

    while let data = compressedData,
          data.count > maxSize,
          compressionQuality > 0.1 {

        compressionQuality -= 0.1
        compressedData = image.jpegData(compressionQuality: compressionQuality)
    }

    return compressedData ?? data
}

func resizedImage(_ image: UIImage, maxDimension: CGFloat = 1600) -> UIImage {
    let size = image.size

    let scale = min(
        maxDimension / size.width,
        maxDimension / size.height,
        1
    )

    let newSize = CGSize(
        width: size.width * scale,
        height: size.height * scale
    )

    let renderer = UIGraphicsImageRenderer(size: newSize)

    return renderer.image { _ in
        image.draw(in: CGRect(origin: .zero, size: newSize))
    }
}

func prepareImageForUpload(_ data: Data) -> Data {
    guard let image = UIImage(data: data) else {
        return data
    }

    let resized = resizedImage(image, maxDimension: 1600)

    return resized.jpegData(compressionQuality: 0.8) ?? data
}

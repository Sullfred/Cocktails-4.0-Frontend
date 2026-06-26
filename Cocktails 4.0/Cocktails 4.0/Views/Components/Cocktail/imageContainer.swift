//
//  view_imageContainer.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 05/08/2025.
//

import SwiftUI

struct imageContainer: View {
    
    var image: UIImage
    var size: CGFloat
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .background(Color.black.opacity(0.2))
            //.aspectRatio(contentMode: .fill)
            .clipShape(Circle())
            .overlay {
                Circle().stroke(.colorSet4, lineWidth: 4)
            }
            .shadow(radius: 7)
            .padding(.leading, 50)
            .padding(.trailing, 50)
    }
}

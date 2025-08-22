//
//  CategoryCard.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 18/08/2025.
//

import SwiftUI

struct CategoryCard: View {
    let title: String
    let imageName: String
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .clipped()
                    .cornerRadius(12)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .foregroundColor(.gray)
                    .padding()
                    .background(Color.secondary.opacity(0.3))
                    .cornerRadius(12)
            }
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(6)
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.6))
        }
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

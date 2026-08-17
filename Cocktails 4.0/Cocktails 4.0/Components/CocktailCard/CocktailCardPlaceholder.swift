//
//  CocktailCardPlaceholder.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 22/07/2026.
//

import SwiftUI

struct CocktailCardPlaceholder: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("🍸")
                .font(.system(size: 60))
            Text("random_waiting")
                .font(.title2)
                .fontWeight(.bold)
            Text("random_try")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 30)
        .padding(.horizontal)
        .frame(width: 350, height: 200)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.backgroundSecondary)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}

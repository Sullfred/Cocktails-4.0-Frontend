//
//  File.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 26/07/2026.
//

import SwiftUI

struct RemovedBy: View {
    var item: HiddenCocktail
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(item.name.capitalized)
            if !item.creator.isEmpty {
                Text("info_by\(item.creator.capitalized)")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            } else {
                Text("info_by_unknown")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            }
        }
    }
}

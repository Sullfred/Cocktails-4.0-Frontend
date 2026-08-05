//
//  SwiftUIView.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 26/07/2026.
//

import SwiftUI

struct RemovedDate: View {
    var item: HiddenCocktail
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("removed_date")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(item.date, format: .dateTime.day().month().year())
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

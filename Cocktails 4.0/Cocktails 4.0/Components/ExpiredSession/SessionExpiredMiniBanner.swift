//
//  SessionExpredMiniBanner.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 27/12/2025.
//

import SwiftUI

struct SessionExpiredMiniBanner: View {
    let minimize: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.slash")
                .font(.caption)
                .foregroundColor(.red)

            HStack(spacing: 20) {
                Text("session_expired")
                    .font(.caption)
                    .foregroundColor(.primary)
                
                
                Image(systemName: "chevron.up")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(radius: 2)
        )
        .padding(.horizontal)
        .onTapGesture {
            minimize()
        }
    }
}

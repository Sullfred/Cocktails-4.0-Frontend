//
//  SessionExpiredBanner.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 26/12/2025.
//

import Foundation
import SwiftUI

struct SessionExpiredBanner: View {
    let onLogin: () -> Void
    let minimize: () -> Void
    let onlogout: () -> Void

    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "lock.slash")
                    .foregroundColor(.white)
                
                Text("session_expired_text")
                    .foregroundColor(.white)
                    .font(.footnote)
            }
            
            HStack(spacing: 12) {
                Button("minimize", action: minimize)
                    .font(.footnote.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("logout", action: onlogout)
                    .font(.footnote.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("login", action: onLogin)
                    .font(.footnote.bold())
                    .foregroundColor(.white)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.red.opacity(0.9))
    }
}

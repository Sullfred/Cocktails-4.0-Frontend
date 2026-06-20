//
//  EnsureAuthHelper.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 28/12/2025.
//

import SwiftUI

func toggleIfAuthenticated(isAuthenticated: Bool, toggleVar: inout Bool) {
    if (isAuthenticated) {
        withAnimation {
            toggleVar.toggle()
        }
    } else {
        ToastManager.shared.show(style: .warning, message: "Login required for this action")
    }
}

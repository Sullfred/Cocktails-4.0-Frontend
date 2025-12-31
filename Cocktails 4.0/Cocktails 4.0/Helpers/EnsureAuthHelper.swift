//
//  EnsureAuthHelper.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 28/12/2025.
//

import SwiftUI

func toggleIfAuthenticated(loggedInUser: LoggedInUser, toggleVar: inout Bool) {
    if (loggedInUser.authState == .authenticated) {
        withAnimation {
            toggleVar.toggle()
        }
    } else {
        ToastManager.shared.show(style: .warning, message: "Login required for this action")
    }
}

//
//  view_MyBarFrontPage.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/09/2025.
//

import SwiftUI

struct view_myBarFrontPage: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                if loginViewModel.isLoggedIn {
                    view_personalBar()
                        .environmentObject(loginViewModel)
                } else {
                    view_login()
                        .environmentObject(loginViewModel)
                }
            }
        }
    }
}

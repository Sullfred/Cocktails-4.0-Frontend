//
//  view_MyBarFrontPage.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/09/2025.
//

import SwiftUI
import SwiftData

struct view_myBarFrontPage: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @EnvironmentObject var myBarViewModel: MyBarViewModel
    @State private var path: [String] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if loginViewModel.isLoggedIn {
                    view_personalBar(path: $path)
                        .environmentObject(loginViewModel)
                        .environmentObject(myBarViewModel)
                } else {
                    view_login()
                        .environmentObject(loginViewModel)
                        .environmentObject(myBarViewModel)
                }
            }
            .navigationDestination(for: String.self) { value in
                if value == "settings" {
                    view_userSettings()
                        .environmentObject(loginViewModel)
                        .environmentObject(myBarViewModel)
                }
            }
        }
        .tint(Color.colorSet4)
        .onChange(of: loginViewModel.isLoggedIn) { _, newValue in
            if !newValue {
                path.removeAll() // reset navigation after logout
            }
        }
    }
}

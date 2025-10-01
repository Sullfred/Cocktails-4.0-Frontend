//
//  ContentView.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 22/07/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    init() {
        UITabBar.appearance().backgroundColor = UIColor.white
    }
    
    @Environment(\.modelContext) var context
    @StateObject private var loginViewModel = LoginViewModel()

    var body: some View {
        TabView {
            view_cocktailsFrontPage()
                .tabItem {
                    Label("Cocktails", systemImage: "list.bullet")
                }
                .environmentObject(loginViewModel)
            view_myBarFrontPage(context: context)
                .tabItem {
                    Label("My Bar", systemImage: "wineglass")
                }
                .environmentObject(loginViewModel)
        }
        .background(Color.colorSet2)
        .tint(Color.colorSet5)
    }
}

#Preview {
    ContentView()
}

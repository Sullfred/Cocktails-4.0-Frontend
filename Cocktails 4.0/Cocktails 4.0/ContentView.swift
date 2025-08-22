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
        UITabBar.appearance().backgroundColor = UIColor.colorSet1
    }
    
    @Environment(\.modelContext) var modelContext

    var body: some View {
        TabView {
            view_cocktailsFrontPage()
                .tabItem {
                    Label("Cocktails", systemImage: "list.bullet")
                }
            view_myBar()
                .tabItem {
                    Label("My Bar", systemImage: "wineglass")
                }
        }
        .background(Color.colorSet2)
        .tint(Color.colorSet5)
    }
}

#Preview {
    ContentView()
}

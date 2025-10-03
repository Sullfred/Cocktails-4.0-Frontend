//
//  ContentView.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 22/07/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var context
    @StateObject private var loginViewModel = LoginViewModel()
    @StateObject private var myBarViewModel: MyBarViewModel
    
    init(context: ModelContext) {
        UITabBar.appearance().backgroundColor = UIColor.white
        _myBarViewModel = StateObject(wrappedValue: MyBarViewModel(context: context))
    }

    var body: some View {
        TabView {
            view_cocktailsFrontPage()
                .tabItem {
                    Label("Cocktails", systemImage: "list.bullet")
                }
                .environmentObject(loginViewModel)
                .environmentObject(myBarViewModel)
            view_myBarFrontPage()
                .tabItem {
                    Label("My Bar", systemImage: "wineglass")
                }
                .environmentObject(loginViewModel)
                .environmentObject(myBarViewModel)
        }
        .background(Color.colorSet2)
        .tint(Color.colorSet5)
    }
}

/*
#Preview {
    ContentView()
}
*/

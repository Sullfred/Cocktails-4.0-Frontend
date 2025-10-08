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
    @StateObject private var userViewModel = UserViewModel()
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
                .environmentObject(userViewModel)
                .environmentObject(myBarViewModel)
            view_myBarFrontPage()
                .tabItem {
                    Label("My Bar", systemImage: "wineglass")
                }
                .environmentObject(userViewModel)
                .environmentObject(myBarViewModel)
        }
        .background(Color.colorSet2)
        .tint(Color.colorSet5)
    }
}

/*
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MyBar.self, configurations: config)
    let context = container.mainContext
    
    ContentView(context: context)
}
*/

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
    @StateObject private var cocktailViewModel: CocktailViewModel
    
    @State private var minimizeBanner: Bool = false
    
    private func toggleBannerSize() {
        minimizeBanner.toggle()
    }
    
    init(context: ModelContext) {
        UITabBar.appearance().backgroundColor = UIColor.white
        _myBarViewModel = StateObject(wrappedValue: MyBarViewModel(context: context))
        _cocktailViewModel = StateObject(wrappedValue: CocktailViewModel(context: context))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView {
                view_cocktailsFrontPage()
                    .tabItem {
                        Label("Cocktails", systemImage: "list.bullet")
                    }
                    .environmentObject(userViewModel)
                    .environmentObject(myBarViewModel)
                    .environmentObject(cocktailViewModel)
                view_myBarFrontPage()
                    .tabItem {
                        Label("My Bar", systemImage: "wineglass")
                    }
                    .environmentObject(userViewModel)
                    .environmentObject(myBarViewModel)
            }
            .background(Color.colorSet2)
            .tint(Color.colorSet5)
            .onAppear(perform: {
                Task {
                    await userViewModel.checkTokenValidity()
                    await myBarViewModel.syncAll()
                    await cocktailViewModel.syncAll()
                    await cocktailViewModel.refresh()
                    
                }
            })
            .sheet(isPresented: $userViewModel.showLogin) {
                view_login()
                    .environmentObject(userViewModel)
                    .environmentObject(myBarViewModel)
            }
            
            if (userViewModel.currentUser?.authState == .expired) {
                if (minimizeBanner == false) {
                    SessionExpiredBanner(onLogin: userViewModel.presentLogin, minimize: toggleBannerSize)
                        .transition(.scale.animation(.easeInOut(duration: 0.3)))
                        .zIndex(1)
                } else {
                    SessionExpiredMiniBanner(minimize: toggleBannerSize)
                        .transition(.scale.animation(.easeInOut(duration: 0.6)))
                        .zIndex(1)
                }
            }
        }
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

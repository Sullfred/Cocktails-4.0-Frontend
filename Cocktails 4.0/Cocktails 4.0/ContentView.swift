//
//  ContentView.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 22/07/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var userViewModel: UserViewModel
    @StateObject private var myBarViewModel: MyBarViewModel
    @StateObject private var cocktailViewModel: CocktailViewModel
    @StateObject private var adminViewModel: AdminViewModel
    @StateObject private var registerViewModel: RegisterViewModel
    
    @State private var isBannerMinimized: Bool = false

    init(dependencies: AppDependencies) {
        _myBarViewModel = StateObject(wrappedValue: MyBarViewModel(dependencies: dependencies))
        _cocktailViewModel = StateObject(wrappedValue: CocktailViewModel(dependencies: dependencies))
        _userViewModel = StateObject(wrappedValue: UserViewModel(dependencies: dependencies))
        _adminViewModel = StateObject(wrappedValue: AdminViewModel(dependencies: dependencies))
        _registerViewModel = StateObject(wrappedValue: RegisterViewModel(dependencies: dependencies))
    }

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                TabView {
                    CocktailsFrontPage()
                        .tabItem {
                            Label("cocktails", systemImage: "list.bullet")
                        }
                        .toolbarBackground(.visible, for: .tabBar)

                    MyBarFrontPage()
                        .tabItem {
                            Label("my_bar", systemImage: "wineglass")
                        }
                        .toolbarBackground(.visible, for: .tabBar)
                }
                .background(Color.background)
                .tint(Color.destructive)
            }

            // MARK: - Session Expiry Banner
            if userViewModel.authState == .expired {
                Group {
                    if isBannerMinimized {
                        SessionExpiredMiniBanner(minimize: toggleBannerSize)
                    } else {
                        SessionExpiredBanner(
                            onLogin: {
                                userViewModel.showLogin = true
                            },
                            minimize: toggleBannerSize
                        )
                    }
                }
                .transition(.scale.animation(.easeInOut(duration: 0.3)))
                .zIndex(1)
                .padding(.top, 24)
            }
        }
        .environmentObject(userViewModel)
        .environmentObject(myBarViewModel)
        .environmentObject(cocktailViewModel)
        .environmentObject(adminViewModel)
        .environmentObject(registerViewModel)
        
        .task {
            await loadInitialData()
        }
        .sheet(isPresented: $userViewModel.showLogin) {
            LoginView()
                .environmentObject(userViewModel)
                .environmentObject(myBarViewModel)
        }
    }

    private func loadInitialData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await userViewModel.verifyTokenStatus() }
            group.addTask { await myBarViewModel.loadLocalBar() }
            group.addTask { await cocktailViewModel.refresh() }
            group.addTask {
                if (await userViewModel.isLoggedIn) {
                    await userViewModel.syncPendingActions()
                }
            }
        }
    }
    
    private func toggleBannerSize() {
        isBannerMinimized.toggle()
    }
}

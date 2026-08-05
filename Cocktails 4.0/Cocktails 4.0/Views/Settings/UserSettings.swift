//
//  view_userSettings.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 24/09/2025.
//

import SwiftUI
import SwiftData
import KeychainSwift

struct UserSettings: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myBarViewModel: MyBarViewModel
    
    @State private var isShowingChangeUsername: Bool = false
    @State private var isShowingChangePassword: Bool = false
    @State private var showLogoutAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    AccountInfoSection()
                    AdminSection()
                    LanguageSection()
                    
                    UserActionsSection(
                        isShowingChangeUsername: $isShowingChangeUsername,
                        isShowingChangePassword: $isShowingChangePassword,
                        toggleUsername: { toggleShowingUserSetting(toggleVar: &isShowingChangeUsername) },
                        togglePassword: { toggleShowingUserSetting(toggleVar: &isShowingChangePassword) }
                    )
                    DestructiveSection(
                        showDeleteAlert: $showDeleteAlert,
                        showLogoutAlert: $showLogoutAlert,
                        onDeleteConfirm: {
                            Task {
                                if (await userViewModel.deleteUser()) {
                                    await myBarViewModel.cleanLocalBar()
                                }
                            }
                        },
                        onLogoutConfirm: {
                            Task {
                                if (await userViewModel.logout()) {
                                    await myBarViewModel.cleanLocalBar()
                                }
                            }
                        },
                        checkBeforeDelete: checkBeforeDelete
                    )
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("user_settings")
    }
    
    func toggleShowingUserSetting(toggleVar: inout Bool) {
        if userViewModel.currentUser != nil {
            toggleIfAuthenticated(isAuthenticated: userViewModel.isLoggedIn, toggleVar: &toggleVar)
        }
    }
    
    func checkBeforeDelete() {
        if (userViewModel.currentUser?.authState == .authenticated) {
            showDeleteAlert = true
        } else {
            ToastManager.shared.show(style: .warning, message: "login_required")
        }
    }
}

#Preview {
    // Create an in-memory model container for previews
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MyBar.self, configurations: config)
    let context = container.mainContext
    
    let dependencies = AppDependencies(context: context)
    let myBarVM = MyBarViewModel(dependencies: dependencies)
    
    UserSettings()
        .environmentObject({
            let vm = UserViewModel(dependencies: dependencies)
            vm.currentUser = LoggedInUser(
                id: UUID(),
                username: "Daniel Vang Kleist",
                role: .admin,
                authState: .authenticated
            )
            return vm
        }())
        .environmentObject(myBarVM)
}

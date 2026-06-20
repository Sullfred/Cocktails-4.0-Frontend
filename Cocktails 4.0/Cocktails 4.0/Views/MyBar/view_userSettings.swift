//
//  view_userSettings.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 24/09/2025.
//

import SwiftUI
import SwiftData
import KeychainSwift

struct view_userSettings: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myBarViewModel: MyBarViewModel
    
    @State private var isShowingChangeUsername: Bool = false
    @State private var isShowingChangePassword: Bool = false
    @State private var showLogoutAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        ZStack {
            Color.colorSet2.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    AccountInfoSection()
                    AdminSection()
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
                            Task { await userViewModel.deleteUser() }
                        },
                        onLogoutConfirm: {
                            Task { await userViewModel.logout() }
                        },
                        checkBeforeDelete: checkBeforeDelete
                    )
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("User Settings")
    }
    
    func toggleShowingUserSetting(toggleVar: inout Bool) {
        if userViewModel.currentUser != nil {
            toggleIfAuthenticated(isAuthenticated: userViewModel.requireAuth, toggleVar: &toggleVar)
        }
    }
    
    func checkBeforeDelete() {
        if (userViewModel.currentUser?.authState == .authenticated) {
            showDeleteAlert = true
        } else {
            ToastManager.shared.show(style: .warning, message: "Login required for this action")
        }
    }
}

private struct AccountInfoSection: View {
    @EnvironmentObject var userViewModel: UserViewModel

    var body: some View {
        GroupBox(label: Label("\(userViewModel.currentUser?.username ?? "Account")", systemImage: "person.crop.circle")) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Role: \(userViewModel.currentUser?.role.rawValue.capitalized ?? "Guest")")
                        .font(.headline)
                        .padding(.bottom, 5)

                    Text("Role Permissions")
                        .font(.title3)

                    if let user = userViewModel.currentUser {
                        if user.role == .admin {
                            Text("Administrator rights").foregroundColor(.secondary)
                        }
                        if user.role == .creator || user.role == .admin {
                            Text("Adding cocktails").foregroundColor(.secondary)
                            Text("Edit cocktails").foregroundColor(.secondary)
                        }
                        if user.role == .guest {
                            Text("None").foregroundColor(.secondary)
                        }
                    } else {
                        Text("Unknown").foregroundColor(.secondary)
                    }
                }
                Spacer()
            }
            .padding(.vertical, 4)
        }
    }
}

private struct AdminSection: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myBarViewModel: MyBarViewModel

    var body: some View {
        if let user = userViewModel.currentUser, user.role == .admin {
            GroupBox(label: Label("Administration", systemImage: "gearshape.2")) {
                if user.authState == .authenticated {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Manage users and permissions.")
                            .foregroundColor(.secondary)

                        NavigationLink {
                            view_adminDashboard()
                        } label: {
                            Label("Open Admin Dashboard", systemImage: "person.3.sequence.fill")
                        }
                    }
                } else {
                    Text("Admin access requires an active session.")
                }
            }
        }
    }
}

private struct UserActionsSection: View {
    @EnvironmentObject var userViewModel: UserViewModel

    @Binding var isShowingChangeUsername: Bool
    @Binding var isShowingChangePassword: Bool

    let toggleUsername: () -> Void
    let togglePassword: () -> Void

    var body: some View {
        VStack(spacing: 6) {

            Button {
                toggleUsername()
            } label: {
                Text("Change Username").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.colorSet4)

            if isShowingChangeUsername {
                ChangeUsername(isShowingChangeUsername: $isShowingChangeUsername)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .environmentObject(userViewModel)
            }

            Button {
                togglePassword()
            } label: {
                Text("Change Password").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.colorSet4)

            if isShowingChangePassword {
                ChangePassword(isShowingChangePassword: $isShowingChangePassword)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .environmentObject(userViewModel)
            }
        }
        .animation(.easeInOut, value: isShowingChangeUsername)
        .animation(.easeInOut, value: isShowingChangePassword)
    }
}

private struct DestructiveSection: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myBarViewModel: MyBarViewModel

    @Binding var showDeleteAlert: Bool
    @Binding var showLogoutAlert: Bool

    let onDeleteConfirm: () -> Void
    let onLogoutConfirm: () -> Void
    let checkBeforeDelete: () -> Void

    var body: some View {
        VStack(spacing: 12) {

            Button(role: .destructive) {
                checkBeforeDelete()
            } label: {
                Text("Delete Account").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Delete Account"),
                    message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete"), action: onDeleteConfirm),
                    secondaryButton: .cancel()
                )
            }

            Button {
                showLogoutAlert = true
            } label: {
                Text("Logout").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .alert(isPresented: $showLogoutAlert) {
                Alert(
                    title: Text("Logout"),
                    message: Text("Are you sure you want to log out?"),
                    primaryButton: .destructive(Text("Logout"), action: onLogoutConfirm),
                    secondaryButton: .cancel()
                )
            }
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
    
    view_userSettings()
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

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
    @Environment(\.modelContext) private var context
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myBarViewModel: MyBarViewModel
    
    @State private var isShowingChangeUsername: Bool = false
    @State private var isShowingChangePassword: Bool = false
    @State private var showLogoutAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        ScrollView {
            Color.colorSet2
                .ignoresSafeArea()
            VStack(spacing: 24) {
                // Account Info
                GroupBox(label: Label("\(userViewModel.currentUser?.username ?? "Account")", systemImage: "person.crop.circle")) {
                    HStack() {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Role: \(userViewModel.currentUser?.role.rawValue.capitalized ?? "Guest")")
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            Text("Role Permissions")
                                .font(.title3)
                            if let user = userViewModel.currentUser {
                                if user.role == .admin {
                                    Text("Administrator rights")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                                if user.role == .creator || user.role == .admin {
                                    Text("Adding cocktails")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Edit cocktails")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                                if user.role == .guest {
                                    Text("None")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                Text("Unknown")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                    }
                    .padding(.vertical, 4)
                }
                
                // Admin section
                if let user = userViewModel.currentUser, user.role == .admin {
                    GroupBox(label: Label("Administration", systemImage: "gearshape.2")) {
                        
                        if (user.authState == .authenticated) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Manage users and permissions.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                NavigationLink {
                                    view_adminDashboard()
                                        .environmentObject(myBarViewModel)
                                } label: {
                                    Label("Open Admin Dashboard", systemImage: "person.3.sequence.fill")
                                        .font(.headline)
                                        .padding(.vertical, 8)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                        } else {
                            Text("Admin access requires an active session.")
                        }
                    }
                }
                
                // User actions
                VStack(spacing: 6) {
                    Button {
                        toggleShowingUserSetting(toggleVar: &isShowingChangeUsername)
                    } label: {
                        Text("Change Username")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.colorSet4)
                    
                    ZStack {
                        if isShowingChangeUsername {
                            ChangeUsername(isShowingChangeUsername: $isShowingChangeUsername)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                                .environmentObject(userViewModel)
                        }
                    }
                    .frame(maxHeight: isShowingChangeUsername ? nil : 0)
                    .clipped()
                    .animation(.easeInOut, value: isShowingChangeUsername)
                    
                    Button {
                        toggleShowingUserSetting(toggleVar: &isShowingChangePassword)
                    } label: {
                        Text("Change Password")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.colorSet4)
                    
                    ZStack {
                        if isShowingChangePassword {
                            ChangePassword(isShowingChangePassword: $isShowingChangePassword)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                                .environmentObject(userViewModel)
                        }
                    }
                    .frame(maxHeight: isShowingChangePassword ? nil : 0)
                    .clipped()
                    .animation(.easeInOut, value: isShowingChangePassword)
                }
                
                // Destructive & Logout actions
                VStack(spacing: 12) {
                    Button(role: .destructive) {
                        checkBeforeDelete()
                    } label: {
                        Text("Delete Account")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .alert(isPresented: $showDeleteAlert) {
                        Alert(
                            title: Text("Delete Account"),
                            message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                            primaryButton: .destructive(Text("Delete")) {
                                Task {
                                    await userViewModel.deleteUser(context: context)
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    Button {
                        showLogoutAlert = true
                    } label: {
                        Text("Logout")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .alert(isPresented: $showLogoutAlert) {
                        Alert(
                            title: Text("Logout"),
                            message: Text("Are you sure you want to log out?"),
                            primaryButton: .destructive(Text("Logout")) {
                                Task {
                                    await userViewModel.logout(myBarViewModel: myBarViewModel)
                                }
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                Spacer()
            }
            .padding()
        }
        .navigationTitle("User Settings")
        .background(Color.colorSet2)
    }
}

private extension view_userSettings {
    func toggleShowingUserSetting(toggleVar: inout Bool) {
        if let loggedInUser = userViewModel.currentUser {
            toggleIfAuthenticated(loggedInUser: loggedInUser, toggleVar: &toggleVar)
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

#Preview {
    // Create an in-memory model container for previews
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MyBar.self, configurations: config)
    let context = container.mainContext
    
    let myBarVM = MyBarViewModel(context: context)
    
    view_userSettings()
        .environmentObject({
            let vm = UserViewModel()
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

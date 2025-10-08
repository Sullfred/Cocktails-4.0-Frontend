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
    
    @State private var isShowingChangeUsername = false
    @State private var isShowingChangePassword = false
    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        ScrollView {
            Color.colorSet2
                .ignoresSafeArea()
            VStack(spacing: 24) {
                // Account Info
                GroupBox(label: Label("\(userViewModel.currentUser?.username ?? "Account")", systemImage: "person.crop.circle")) {
                    HStack() {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("User Permissions")
                                .font(.title3)
                            if let user = userViewModel.currentUser {
                                if user.addPermission {
                                    Text("Adding cocktails")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                                if user.editPermissions {
                                    Text("Edit cocktails")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                                if user.adminRights {
                                    Text("Administrator rights")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                                if !user.addPermission && !user.editPermissions && !user.adminRights {
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
                
                // User actions
                VStack(spacing: 6) {
                    Button {
                        withAnimation {
                            isShowingChangeUsername.toggle()
                        }
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
                        withAnimation {
                            isShowingChangePassword.toggle()
                        }
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
                        showDeleteAlert = true
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
    func permissionsText() -> String {
        guard let user = userViewModel.currentUser else { return "Unknown" }
        var perms: [String] = []
        if user.addPermission { perms.append("Add") }
        if user.editPermissions { perms.append("Edit") }
        if user.adminRights { perms.append("Admin") }
        if perms.isEmpty { return "None" }
        return perms.joined(separator: ", ")
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
                addPermission: true,
                editPermissions: true,
                adminRights: false
            )
            return vm
        }())
        .environmentObject(myBarVM)
}

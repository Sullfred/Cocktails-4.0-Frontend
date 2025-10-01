//
//  view_userSettings.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 24/09/2025.
//

import SwiftUI
import KeychainSwift

struct view_userSettings: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject var loginViewModel: LoginViewModel
    
    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        ZStack {
            Color.colorSet2
                .ignoresSafeArea()
            VStack(spacing: 24) {
                // Account Info
                GroupBox(label: Label("\(loginViewModel.currentUser?.username ?? "Account")", systemImage: "person.crop.circle")) {
                    HStack() {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("User Permissions")
                                .font(.title3)
                            if let user = loginViewModel.currentUser {
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
                VStack(spacing: 12) {
                    Button {
                        print("Change Username tapped")
                    } label: {
                        Text("Change Username")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.colorSet4)
                    Button {
                        print("Change Password tapped")
                    } label: {
                        Text("Change Password")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.colorSet4)
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
                                    await loginViewModel.deleteUser(context: context)
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
                                    await loginViewModel.logout(context: context)
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
    }
}

private extension view_userSettings {
    func permissionsText() -> String {
        guard let user = loginViewModel.currentUser else { return "Unknown" }
        var perms: [String] = []
        if user.addPermission { perms.append("Add") }
        if user.editPermissions { perms.append("Edit") }
        if user.adminRights { perms.append("Admin") }
        if perms.isEmpty { return "None" }
        return perms.joined(separator: ", ")
    }
}

#Preview {
    view_userSettings()
        .environmentObject({
            let vm = LoginViewModel()
            vm.currentUser = LoggedInUser(
                id: UUID(),
                username: "Daniel Vang Kleist",
                addPermission: true,
                editPermissions: true,
                adminRights: false
            )
            return vm
        }())
}

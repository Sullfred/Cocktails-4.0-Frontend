//
//  view_userRoles.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 21/10/2025.
//

import SwiftUI

struct view_userRoles: View {
    @EnvironmentObject var adminViewModel: AdminViewModel
    
    @State private var users: [fetchPublicUserDTO] = []
    @State private var selectedRoles: [UUID: UserRole] = [:]
    @State private var isSuccess: Bool = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if users.isEmpty {
                    Text("No users found")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    ForEach(users, id: \.id) { user in
                        VStack(alignment: .leading, spacing: 10) {
                            
                            HStack {
                                Text(user.username)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Picker("\(user.role.rawValue.capitalized)", selection: $selectedRoles[user.id]) {
                                    Text("Guest").tag(UserRole.guest)
                                    Text("Creator").tag(UserRole.creator)
                                }
                                .frame(width: 120)
                            }
                            
                            // Confirm button to ensure no wrong role is given
                            if let selectedRole = selectedRoles[user.id], selectedRole != user.role {
                                Button {
                                    Task {
                                        let success = await adminViewModel.updateUserRole(userID: user.id, newRole: selectedRole)
                                        
                                        // if succes give visual feedback before hiding button
                                        if success {
                                            isSuccess = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                withAnimation {
                                                    isSuccess = false
                                                }
                                                // Update role locally
                                                if let index = users.firstIndex(where: { $0.id == user.id }) {
                                                    users[index].role = selectedRole
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    if adminViewModel.isLoading {
                                        ProgressView()
                                            .frame(maxWidth: .infinity)
                                    } else if isSuccess {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .frame(maxWidth: .infinity)
                                    } else {
                                        Text("Confirm Change")
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(Color.colorSet4)
                                .padding(.horizontal)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }
                            
                        }
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 5)
                    }
                }
            }
        }
        .task {
            users = await adminViewModel.fetchUsers()
            selectedRoles = Dictionary(uniqueKeysWithValues: users.map { ($0.id, $0.role) })
        }
    }
}

#Preview {
    view_userRoles()
        .environmentObject(AdminViewModel())
}

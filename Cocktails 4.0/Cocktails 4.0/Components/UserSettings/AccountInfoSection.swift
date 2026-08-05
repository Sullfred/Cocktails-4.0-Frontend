//
//  AccountInfoSection.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 24/07/2026.
//

import SwiftUI

struct AccountInfoSection: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var localizationManager: LocalizationManager

    var body: some View {
        GroupBox(label: Label("\(userViewModel.currentUser?.username ?? "account")", systemImage: "person.crop.circle")) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("role\(userViewModel.currentUser?.role.rawValue.capitalized ?? "guest")")
                        .font(.headline)
                        .foregroundStyle(Color.textTitle)
                        .padding(.bottom, 5)

                    Text("role_permissions")
                        .font(.title3)
                        .foregroundStyle(Color.textTitle)

                    if let user = userViewModel.currentUser {
                        if user.role == .admin {
                            Text("admin_rights")
                                .foregroundColor(Color.textSecondary)
                        }
                        if user.role == .creator || user.role == .admin {
                            Text("creator_rights1")
                                .foregroundColor(Color.textSecondary)
                            Text("creator_rights2")
                                .foregroundColor(Color.textSecondary)
                        }
                        if user.role == .guest {
                            Text("none")
                                .foregroundColor(Color.textSecondary)
                        }
                    } else {
                        Text("unknown")
                            .foregroundColor(Color.textSecondary)
                    }
                }
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .backgroundStyle(Color.backgroundSecondary)
    }
}

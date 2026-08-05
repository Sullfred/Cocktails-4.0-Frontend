//
//  AdminSection.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 24/07/2026.
//

import SwiftUI

struct AdminSection: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myBarViewModel: MyBarViewModel

    var body: some View {
        if let user = userViewModel.currentUser, user.role == .admin {
            GroupBox(label: Label("administration", systemImage: "gearshape.2")) {
                if user.authState == .authenticated {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("manage_permissions")
                            .foregroundColor(Color.textSecondary)

                        NavigationLink {
                            AdminDashboard()
                        } label: {
                            Label("admin_dashboard", systemImage: "person.3.sequence.fill")
                        }
                    }
                } else {
                    Text("admin_access")
                }
            }
            .backgroundStyle(Color.backgroundSecondary)
        }
    }
}

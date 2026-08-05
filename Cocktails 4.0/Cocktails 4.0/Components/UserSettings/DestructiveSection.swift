//
//  DestructiveSection.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 24/07/2026.
//

import SwiftUI

struct DestructiveSection: View {
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
                Text("delete_account").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("delete_account"),
                    message: Text("delete_account_confirm"),
                    primaryButton: .destructive(Text("delete"), action: onDeleteConfirm),
                    secondaryButton: .cancel()
                )
            }

            Button {
                showLogoutAlert = true
            } label: {
                Text("logout").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .alert(isPresented: $showLogoutAlert) {
                Alert(
                    title: Text("logout"),
                    message: Text("logout_confirm"),
                    primaryButton: .destructive(Text("logout"), action: onLogoutConfirm),
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

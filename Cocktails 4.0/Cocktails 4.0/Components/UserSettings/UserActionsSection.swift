//
//  UserActionsSection.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 24/07/2026.
//

import SwiftUI

struct UserActionsSection: View {
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
                Text("change_username").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.textPrimary)

            if isShowingChangeUsername {
                ChangeUsername(isShowingChangeUsername: $isShowingChangeUsername)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Button {
                togglePassword()
            } label: {
                Text("change_password").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.textPrimary)

            if isShowingChangePassword {
                ChangePassword(isShowingChangePassword: $isShowingChangePassword)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut, value: isShowingChangeUsername)
        .animation(.easeInOut, value: isShowingChangePassword)
    }
}

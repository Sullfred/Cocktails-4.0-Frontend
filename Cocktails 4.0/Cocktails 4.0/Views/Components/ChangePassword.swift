//
//  ChangePassword.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 07/10/2025.
//

import SwiftUI

struct ChangePassword: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    @Binding var isShowingChangePassword: Bool
    
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var ConfirmNewPassword: String = ""
    
    @State private var showCurrentPassword: Bool = false
    @State private var showNewPassword: Bool = false
    @State private var showConfirmNewPassword: Bool = false
    
    @State private var isLoading: Bool = false
    @State private var isSuccess: Bool = false
    
    private var valid: Bool {
        !currentPassword.isEmpty &&
        newPassword.count >= 8 &&
        newPassword == ConfirmNewPassword
    }
    
    var body: some View {
        VStack(spacing: 8) {
            
            // Current password
            ZStack(alignment: .trailing) {
                Group {
                    if showCurrentPassword {
                        TextField("Current Password", text: $currentPassword)
                    } else {
                        SecureField("Current Password", text: $currentPassword)
                    }
                }
                .textContentType(.password)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                
                Button(action: {
                    showCurrentPassword.toggle()
                }) {
                    Image(systemName: showCurrentPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 16)
            }
            
            // New password
            ZStack(alignment: .trailing) {
                Group {
                    if showNewPassword {
                        TextField("New Password", text: $newPassword)
                    } else {
                        SecureField("New Password", text: $newPassword)
                    }
                }
                .textContentType(.password)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                
                Button(action: {
                    showNewPassword.toggle()
                }) {
                    Image(systemName: showNewPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 16)
            }
            
            // Confirm new password
            ZStack(alignment: .trailing) {
                Group {
                    if showConfirmNewPassword {
                        TextField("Confirm New Password", text: $ConfirmNewPassword)
                    } else {
                        SecureField("Confirm New Password", text: $ConfirmNewPassword)
                    }
                }
                .textContentType(.password)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                
                Button(action: {
                    showConfirmNewPassword.toggle()
                }) {
                    Image(systemName: showConfirmNewPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 16)
            }
            
            if let error = userViewModel.errorMessage, !error.isEmpty {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.top, -8)
            }
            
            HStack {
                Button {
                    withAnimation {
                        currentPassword = ""
                        newPassword = ""
                        ConfirmNewPassword = ""
                        isShowingChangePassword.toggle()
                    }
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.colorSet5)
                
                Spacer()
                
                Button {
                    Task {
                        isLoading = true
                        userViewModel.errorMessage = nil
                        let success = await userViewModel.updatePassword(currentPassword: currentPassword, newPassword: newPassword, confirmNewPassword: ConfirmNewPassword)
                        isLoading = false
                        if success {
                            isSuccess = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isSuccess = false
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation {
                                    isShowingChangePassword.toggle()
                                    currentPassword = ""
                                    newPassword = ""
                                    ConfirmNewPassword = ""
                                }
                            }
                        }
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else if isSuccess {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.colorSet4)
                .disabled(!valid || isLoading)
            }
            .padding()
        }
        .padding(.bottom, 15)
    }
}

#Preview {
    @Previewable @State var value: Bool = true
    
    ChangePassword(isShowingChangePassword: $value)
        .environmentObject(UserViewModel())
}

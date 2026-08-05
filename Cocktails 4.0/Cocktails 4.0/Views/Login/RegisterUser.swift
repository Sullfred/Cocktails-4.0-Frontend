//
//  view_registerUser.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 20/09/2025.
//

import SwiftUI

struct RegisterUser: View {
    @EnvironmentObject var registerViewModel: RegisterViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack{
                Text("login_register")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Text("login_register_new_account")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.bottom, 10)
            }
            
            VStack(spacing: 20) {
                // Username
                TextField("login_username", text: $registerViewModel.username)
                    .textContentType(.username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                
                // Password
                ZStack(alignment: .trailing) {
                    Group {
                        if registerViewModel.showPassword {
                            TextField("login_password_create", text: $registerViewModel.password)
                        } else {
                            SecureField("login_password_create", text: $registerViewModel.password)
                        }
                    }
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    
                    Button(action: {
                        registerViewModel.showPassword.toggle()
                    }) {
                        Image(systemName: registerViewModel.showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 16)
                }
                
                // Confirm Password
                ZStack(alignment: .trailing) {
                    Group {
                        if registerViewModel.showConfirmPassword {
                            TextField("login_password_confirm", text: $registerViewModel.confirmPassword)
                        } else {
                            SecureField("login_password_confirm", text: $registerViewModel.confirmPassword)
                        }
                    }
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    
                    Button(action: {
                        registerViewModel.showConfirmPassword.toggle()
                    }) {
                        Image(systemName: registerViewModel.showConfirmPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 16)
                }
                
                // Error
                if !registerViewModel.errorMessage.isEmpty {
                    Text(registerViewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.bottom, 5)
                }
            }
            
            // Register button
            Button(action: {
                Task {
                    await registerViewModel.register()
                    
                    // Reset username, password and confirmPassword
                    registerViewModel.username = ""
                    registerViewModel.password = ""
                    registerViewModel.confirmPassword = ""
                }
            }) {
                if registerViewModel.isLoading {
                    ProgressView()
                } else {
                    Text("login_create_account")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(registerViewModel.formIsValid ? Color.textPrimary : Color.gray.opacity(0.4))
                        .foregroundColor(registerViewModel.formIsValid ? Color.white : Color.gray)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
            .disabled(!registerViewModel.formIsValid || registerViewModel.isLoading)
            
            Spacer()
        }
        .padding(20)
        .background(Color.background.ignoresSafeArea())
        // Watch for success and dismiss
        .onChange(of: registerViewModel.didRegister) { dismiss() }
    }
}

#Preview {
    RegisterUser()
}

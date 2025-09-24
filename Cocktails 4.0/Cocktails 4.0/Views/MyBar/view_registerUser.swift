//
//  view_registerUser.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 20/09/2025.
//

import SwiftUI

struct view_registerUser: View {
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack{
                Text("Register")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Text("Create a New Account")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.bottom, 10)
            }
            
            VStack(spacing: 20) {
                // Username
                TextField("Username", text: $viewModel.username)
                    .textContentType(.username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                
                // Password
                ZStack(alignment: .trailing) {
                    Group {
                        if viewModel.showPassword {
                            TextField("Password (min. 8 chars)", text: $viewModel.password)
                        } else {
                            SecureField("Password (min. 8 chars)", text: $viewModel.password)
                        }
                    }
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    
                    Button(action: {
                        viewModel.showPassword.toggle()
                    }) {
                        Image(systemName: viewModel.showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 16)
                }
                
                // Confirm Password
                ZStack(alignment: .trailing) {
                    Group {
                        if viewModel.showPassword {
                            TextField("Confirm Password", text: $viewModel.password)
                        } else {
                            SecureField("Confirm Password", text: $viewModel.password)
                        }
                    }
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    
                    Button(action: {
                        viewModel.showPassword.toggle()
                    }) {
                        Image(systemName: viewModel.showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 16)
                }
                
                // Error
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.bottom, 5)
                }
            }
            
            // Register button
            Button(action: { Task { await viewModel.register() } }) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Create Account")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.formIsValid ? Color.colorSet4 : Color.gray.opacity(0.4))
                        .foregroundColor(viewModel.formIsValid ? Color.white : Color.gray)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
            .disabled(!viewModel.formIsValid || viewModel.isLoading)
            
            Spacer()
        }
        .padding(20)
        .background(Color.colorSet2.ignoresSafeArea())
        // Watch for success and dismiss
        .onChange(of: viewModel.didRegister) { dismiss() }
    }
}

#Preview {
    view_registerUser()
}

//
//  view_login.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 20/09/2025.
//

import SwiftUI

struct view_login: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
                Text("Login to MyBar")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
            
            VStack(spacing: 20) {
                TextField("Username", text: $loginViewModel.username)
                    .textContentType(.username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                
                ZStack(alignment: .trailing) {
                    Group {
                        if isPasswordVisible {
                            TextField("Password", text: $loginViewModel.password)
                        } else {
                            SecureField("Password", text: $loginViewModel.password)
                        }
                    }
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 16)
                }
                if let error = loginViewModel.errorMessage, !error.isEmpty {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.top, -8)
                }
            }
            VStack(spacing: 16) {
                Button(action: {
                    Task {
                        await loginViewModel.login()
                        
                        // Reset username and password after a login
                        loginViewModel.username = ""
                        loginViewModel.password = ""
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.colorSet4)
                            .frame(height: 48)
                        if loginViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Login")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .disabled(loginViewModel.isLoading)
                
                NavigationLink {
                    view_registerUser()
                } label: {
                    Text("Don't have an account? Register")
                        .font(.footnote)
                }
            }
            Spacer()
        }
        .padding(20)
        .background(Color.colorSet2.ignoresSafeArea())
    }
}

#Preview {
    view_login()
        .environmentObject(LoginViewModel())
}

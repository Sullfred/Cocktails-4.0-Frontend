//
//  view_login.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 20/09/2025.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myBarViewModel: MyBarViewModel
    
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text("login_intro")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
            
            VStack(spacing: 20) {
                TextField(
                    "",
                    text: $userViewModel.username,
                    prompt: Text("login_username").foregroundStyle(Color.textSecondary)
                )
                    .textContentType(.username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.white)
                    .foregroundStyle(Color.black)
                    .cornerRadius(10)
                
                ZStack(alignment: .trailing) {
                    Group {
                        if isPasswordVisible {
                            TextField(
                                "",
                                text: $userViewModel.password,
                                prompt: Text("login_password").foregroundStyle(Color.textSecondary)
                            )
                        } else {
                            SecureField(
                                "",
                                text: $userViewModel.password,
                                prompt: Text("login_password").foregroundStyle(Color.textSecondary)
                            )
                        }
                    }
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.white)
                    .foregroundStyle(Color.black)
                    .cornerRadius(10)
                    
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
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
            }
            VStack(spacing: 16) {
                Button(action: {
                    Task {
                        if (await userViewModel.login()) {
                            await myBarViewModel.GetPersonalBar()
                        }
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.textPrimary)
                            .frame(height: 48)
                        if userViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("login")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .disabled(userViewModel.isLoading)
                
                NavigationLink {
                    RegisterUser()
                } label: {
                    Text("login_register_now")
                        .font(.footnote)
                }
            }
            Spacer()
        }
        .padding(20)
        .background(Color.background)
    }
}

#Preview {
    LoginView()
}

//
//  view_login.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 20/09/2025.
//

import SwiftUI
import SwiftData

struct view_login: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myBarViewModel: MyBarViewModel
    
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
                Text("Login to MyBar")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
            
            VStack(spacing: 20) {
                TextField("Username", text: $userViewModel.username)
                    .textContentType(.username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                
                ZStack(alignment: .trailing) {
                    Group {
                        if isPasswordVisible {
                            TextField("Password", text: $userViewModel.password)
                        } else {
                            SecureField("Password", text: $userViewModel.password)
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
                        await userViewModel.login(myBarViewModel: myBarViewModel)
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.colorSet4)
                            .frame(height: 48)
                        if userViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Login")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .disabled(userViewModel.isLoading)
                
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
    // Create an in-memory model container for previews
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MyBar.self, configurations: config)
    let context = container.mainContext
    
    let myBarVM = MyBarViewModel(context: context)
    
    view_login()
        .environmentObject(UserViewModel())
        .environmentObject(myBarVM)
}

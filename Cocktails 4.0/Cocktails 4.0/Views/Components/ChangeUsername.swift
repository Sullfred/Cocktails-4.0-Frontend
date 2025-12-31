//
//  ChangeUsername.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 07/10/2025.
//

import SwiftUI

struct ChangeUsername: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    @Binding var isShowingChangeUsername: Bool
    @State private var newUsername: String = ""
    @State private var isSuccess: Bool = false
    
    var body: some View {
        
        VStack(spacing: 8) {
            TextField("New Username", text: $newUsername)
                .textContentType(.username)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
            
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
                        newUsername = ""
                        isShowingChangeUsername.toggle()
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
                        let success = await userViewModel.updateUsername(newUsername: newUsername)
                        if success {
                            isSuccess = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isSuccess = false
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation {
                                    isShowingChangeUsername.toggle()
                                }
                                newUsername = ""
                            }
                        }
                    }
                } label: {
                    if userViewModel.isLoading {
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
                .disabled(newUsername.isEmpty || userViewModel.isLoading)
            }
            .padding()
        }
        .padding(.bottom, 15)
    }
}

#Preview {
    @Previewable @State var value: Bool = true
    ChangeUsername(isShowingChangeUsername: $value)
        .environmentObject(UserViewModel())
}

//
//  view_MyBarFrontPage.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/09/2025.
//

import SwiftUI
import SwiftData

struct MyBarFrontPage: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myBarViewModel: MyBarViewModel
    @State private var path: [String] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if userViewModel.isLoggedIn {
                    PersonalBar(path: $path)
                } else {
                    LoginView()
                }
            }
            .navigationDestination(for: String.self) { value in
                if value == "settings" {
                    UserSettings()
                }
            }
        }
        .tint(Color.textPrimary)
        .onChange(of: userViewModel.isLoggedIn) { _, newValue in
            if !newValue {
                path.removeAll() // reset navigation after logout
            }
        }
    }
}

#Preview {
    // Create an in-memory model container for previews
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MyBar.self, configurations: config)
    let context = container.mainContext
    
    let dependencies = AppDependencies(context: context)
    let myBarVM = MyBarViewModel(dependencies: dependencies)
    
    MyBarFrontPage()
        .environmentObject({
            let vm = UserViewModel(dependencies: dependencies)
            vm.currentUser = LoggedInUser(
                id: UUID(),
                username: "Daniel Vang Kleist",
                role: .admin,
                authState: .authenticated
            )
            return vm
        }())
        .environmentObject(myBarVM)
}

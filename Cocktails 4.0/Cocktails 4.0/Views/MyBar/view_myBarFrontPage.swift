//
//  view_MyBarFrontPage.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/09/2025.
//

import SwiftUI
import SwiftData

struct view_myBarFrontPage: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myBarViewModel: MyBarViewModel
    @State private var path: [String] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if userViewModel.isLoggedIn {
                    view_personalBar(path: $path)
                        .environmentObject(userViewModel)
                        .environmentObject(myBarViewModel)
                } else {
                    view_login()
                        .environmentObject(userViewModel)
                        .environmentObject(myBarViewModel)
                }
            }
            .navigationDestination(for: String.self) { value in
                if value == "settings" {
                    view_userSettings()
                        .environmentObject(userViewModel)
                        .environmentObject(myBarViewModel)
                }
            }
        }
        .tint(Color.colorSet4)
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
    
    let myBarVM = MyBarViewModel(context: context)
    
    view_myBarFrontPage()
        .environmentObject({
            let vm = UserViewModel()
            vm.currentUser = LoggedInUser(
                id: UUID(),
                username: "Daniel Vang Kleist",
                addPermission: true,
                editPermissions: true,
                adminRights: false
            )
            return vm
        }())
        .environmentObject(myBarVM)
}

//
//  view_dashboardContent.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/10/2025.
//

import SwiftUI

struct view_dashboardContent: View {
    @EnvironmentObject var adminViewModel: AdminViewModel
    @EnvironmentObject var myBarViewModel: MyBarViewModel
    
    @State private var isShowingUserRoles = false
    @State private var isShowingDeleteCocktails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // User management
            categoryHeader("User Management")
            
            Button {
                withAnimation {
                    isShowingUserRoles.toggle()
                }
            } label: {
                Text("Update User Roles")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.colorSet4)
            
            ZStack {
                if isShowingUserRoles {
                    view_userRoles()
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .environmentObject(adminViewModel)
                }
            }
            .frame(maxHeight: isShowingUserRoles ? nil : 0)
            .clipped()
            .animation(.easeInOut, value: isShowingUserRoles)
            
            // Cocktail management
            categoryHeader("Cocktail Management")
            Button {
                withAnimation {
                    isShowingDeleteCocktails.toggle()
                }
            } label: {
                Text("Delete removed Cocktails")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.colorSet4)
            
            ZStack {
                if isShowingDeleteCocktails {
                    view_deleteCocktails()
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .environmentObject(adminViewModel)
                        .environmentObject(myBarViewModel)
                }
            }
            .frame(maxHeight: isShowingDeleteCocktails ? nil : 0)
            .clipped()
            .animation(.easeInOut, value: isShowingDeleteCocktails)
        }
        .padding()
    }
}

@ViewBuilder
private func categoryHeader(_ header: String) -> some View {
    HStack {
        Text(header.capitalized)
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(Color.colorSet4)
        Spacer()
    }
    .padding(.vertical, 6)
    .padding(.leading, 8)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.colorSet2)
}

#Preview {
    view_dashboardContent()
}

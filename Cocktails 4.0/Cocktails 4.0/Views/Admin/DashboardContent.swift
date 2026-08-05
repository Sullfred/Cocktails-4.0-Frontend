//
//  view_dashboardContent.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/10/2025.
//

import SwiftUI

struct DashboardContent: View {
    @EnvironmentObject var adminViewModel: AdminViewModel
    @EnvironmentObject var myBarViewModel: MyBarViewModel
    
    @State private var isShowingUserRoles = false
    @State private var isShowingDeleteCocktails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // User management
            categoryHeader("admin_dashboard_user_mangement")
            
            Button {
                withAnimation {
                    isShowingUserRoles.toggle()
                }
            } label: {
                Text("admin_dashboard_user_roles")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.textPrimary)
            
            ZStack {
                if isShowingUserRoles {
                    UserRoles()
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .frame(maxHeight: isShowingUserRoles ? nil : 0)
            .clipped()
            .animation(.easeInOut, value: isShowingUserRoles)
            
            // Cocktail management
            categoryHeader("admin_dashboard_cocktail_mangement")
            Button {
                withAnimation {
                    isShowingDeleteCocktails.toggle()
                }
            } label: {
                Text("admin_dashboard_delete_cocktails")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.textPrimary)
            
            ZStack {
                if isShowingDeleteCocktails {
                    DeleteCocktails()
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
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
private func categoryHeader(_ header: LocalizedStringKey) -> some View {
    HStack {
        Text(header)
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(Color.textPrimary)
        Spacer()
    }
    .padding(.vertical, 6)
    .padding(.leading, 8)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.background)
}

#Preview {
    DashboardContent()
}

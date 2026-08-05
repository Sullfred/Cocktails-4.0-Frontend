//
//  view_adminSettings.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 17/10/2025.
//

import SwiftUI

import SwiftUI

struct AdminDashboard: View {
    @EnvironmentObject var adminViewModel: AdminViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            Color.background
                .ignoresSafeArea()
            
            if adminViewModel.isCheckingConnection {
                ProgressView("server_check_connection")
                    .padding()
            } else if adminViewModel.isConnected {
                DashboardContent()
            } else {
                VStack(spacing: 12) {
                    
                    Spacer()
                    
                    Label("server_not_connected", systemImage: "wifi.exclamationmark")
                        .foregroundColor(.secondary)
                    Button("retry") {
                        Task { await adminViewModel.checkServerConnection() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.textPrimary)
                    
                    Spacer()
                }
            }
        }
        .navigationTitle("admin_dashboard_title")
        .padding()
        .background(Color.background)
        .task {
            await adminViewModel.checkServerConnection()
        }
        .refreshable {
            await adminViewModel.checkServerConnection()
        }
    }
}

#Preview {
    AdminDashboard()
}

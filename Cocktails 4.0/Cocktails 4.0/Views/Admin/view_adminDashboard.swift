//
//  view_adminSettings.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 17/10/2025.
//

import SwiftUI

import SwiftUI

struct view_adminDashboard: View {
    @StateObject private var adminViewModel = AdminViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var myBarViewModel: MyBarViewModel
    
    var body: some View {
        ScrollView {
            Color.colorSet2
                .ignoresSafeArea()
            
            if adminViewModel.isCheckingConnection {
                ProgressView("Checking server connection...")
                    .padding()
            } else if adminViewModel.isConnected {
                view_dashboardContent()
                    .environmentObject(adminViewModel)
                    .environmentObject(myBarViewModel)
            } else {
                VStack(spacing: 12) {
                    
                    Spacer()
                    
                    Label("Not connected to server", systemImage: "wifi.exclamationmark")
                        .foregroundColor(.secondary)
                    Button("Retry") {
                        Task { await adminViewModel.checkServerConnection() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.colorSet4)
                    
                    Spacer()
                }
            }
        }
        .navigationTitle("Admin Dashboard")
        .padding()
        .background(Color.colorSet2)
        .task {
            await adminViewModel.checkServerConnection()
        }
        .refreshable {
            await adminViewModel.checkServerConnection()
        }
    }
}

#Preview {
    view_adminDashboard()
}

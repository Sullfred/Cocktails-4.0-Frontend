//
//  barItemRow.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 25/09/2025.
//

import SwiftUI

struct barItemRow: View {
    @EnvironmentObject var myBarViewModel: MyBarViewModel
    
    var barItem: MyBarItem
    
    @State private var deleteConfirmationItem: MyBarItem? = nil
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        HStack {
            Text(barItem.name.capitalized)
            
            Spacer()
            
            Divider()
            
            Button(action: {
                withAnimation {
                    deleteItem(barItem)
                }
            }) {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(.colorSet5)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.trailing, 10)
        .padding(.leading, 10)
        .alert("Delete Item?", isPresented: Binding(get: { deleteConfirmationItem != nil }, set: { if !$0 { deleteConfirmationItem = nil }})) {
            Button("Delete", role: .destructive) {
                if let item = deleteConfirmationItem {
                    deleteItem(item)
                }
                deleteConfirmationItem = nil
            }
            Button("Cancel", role: .cancel) {
                deleteConfirmationItem = nil
            }
        } message: {
            Text("Are you sure you want to delete \"\(deleteConfirmationItem?.name.capitalized ?? "")\"?")
        }
    }
    
    func deleteItem(_ item: MyBarItem) {
        Task {
            await myBarViewModel.deleteBarItem(barItem)
        }
    }
}




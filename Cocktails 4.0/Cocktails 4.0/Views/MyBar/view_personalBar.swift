//
//  view_Bar.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 22/07/2025.
//

import SwiftUI
import SwiftData

struct view_personalBar: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var bars: [MyBar]
    
    @EnvironmentObject var loginViewModel: LoginViewModel
    
    @State private var newItemName: String = ""
    @State private var newItemCategory: BarItemCategory? = nil
    
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(alignment: .leading) {
                HStack {
                    NavigationLink(destination: view_notes()) {
                        Label("Guide", systemImage: "note.text")
                    }
                }
                .padding(.leading, 15)
                
                
                Text("\(loginViewModel.currentUser?.username ?? "My")'s Bar Items")
                    .font(.title)
                    .padding(.top, 15)
                    .padding(.leading, 15)
                
                List {
                    ForEach(BarItemCategory.allCases, id: \.self) { category in
                        let itemsInCategory = (bars.first?.myBarItems ?? []).filter { $0.category == category }
                        if !itemsInCategory.isEmpty {
                            
                            Section {
                                VStack(alignment: .leading) {
                                    ForEach(itemsInCategory) { item in
                                        HStack {
                                            Text(item.name.capitalized)
                                            
                                            Spacer()
                                            
                                            Divider()
                                            
                                            Button(action: {
                                                withAnimation {
                                                    bars.first?.myBarItems.removeAll { $0.id == item.id }
                                                }
                                            }) {
                                                Image(systemName: "minus.circle.fill")
                                                    .foregroundStyle(.colorSet5)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                            }header: {
                                Text(category.rawValue.capitalized)
                                    .font(.headline)
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                    .background(Color.clear)
                }
                .scrollContentBackground(.hidden)
                
                Divider()
                
                HStack(alignment: .lastTextBaseline) {
                    VStack(alignment: .leading){
                        Text("Add a new item")
                            .font(.callout)
                            .foregroundStyle(Color.colorSet4)
                        TextField("New Bar Item Name", text: $newItemName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .trailing){
                        Text("Category")
                            .font(.callout)
                            .foregroundStyle(Color.colorSet4)
                        Picker("Category", selection: $newItemCategory) {
                            Text("Auto-assign").tag(nil as BarItemCategory?)
                            ForEach(BarItemCategory.allCases, id: \.self) { category in
                                Text(category.rawValue.capitalized).tag(category as BarItemCategory?)
                            }
                        }
                    }
                    
                    Button("Add") {
                        add_item()
                    }
                    .disabled(newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }
        .navigationTitle("\(loginViewModel.currentUser?.username ?? "My")'s Bar")
        .background(Color.colorSet2)
        .tint(Color.colorSet4)
        .alert("Add Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
}


private extension view_personalBar {
    func add_item() {
        do {
            let trimmedName = newItemName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty else { return }
            let newItem = MyBarItem(name: trimmedName.lowercased())
            if let selectedCategory = newItemCategory {
                newItem.category = selectedCategory
            } else {
                newItem.assignCategoryBasedOnName()
            }
            if let bar = bars.first {
                bar.myBarItems.append(newItem)
            } else {
                let newBar = MyBar()
                newBar.myBarItems.append(newItem)
                modelContext.insert(newBar)
            }
            try modelContext.save()
            newItemName = ""
            newItemCategory = nil
        } catch {
            errorMessage = "Failed to save bar item: \(error.localizedDescription)"
            showError = true
        }
    }
}

#Preview {
        view_personalBar()
            .environmentObject({
                let vm = LoginViewModel()
                vm.currentUser = LoggedInUser(
                    username: "PreviewUser",
                    addPermission: false,
                    editPermissions: false,
                    adminRights: false
                )
                return vm
            }())
}

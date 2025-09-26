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
    
    @Binding var path: [String]
    
    @State private var newItemName: String = ""
    @State private var newItemCategory: BarItemCategory? = nil
    
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                NavigationLink(destination: view_notes()) {
                    Label("Guide", systemImage: "note.text")
                        .font(.headline)
                }
                Spacer()
            }
            .padding(.horizontal, 15)
            .padding(.top, 10)
            
            if let bar = bars.first {
                Text("\(loginViewModel.currentUser?.username.components(separatedBy: " ").first ?? "My")'s Bar Items")
                    .font(.largeTitle.weight(.bold))
                    .padding(.horizontal, 15)
                
                if bar.myBarItems.isEmpty {
                    
                    Spacer()
                    
                    HStack(){
                        Spacer()
                        
                        Text("Bar is Empty")
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                } else {
                    barItemList(bar: bar)
                }
                
            } else {
                Spacer()
                
                HStack(){
                    Spacer()
                    
                    Text("No Bar Found")
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                
                Spacer()
            }
            
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
                
                Button(action: add_item) {
                    Text("Add")
                        .frame(minWidth: 25)
                }
                .buttonStyle(.borderedProminent)
                .disabled(newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationTitle("\(loginViewModel.currentUser?.username.components(separatedBy: " ").first ?? "My")'s Bar")
        .background(Color.colorSet2)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    path.append("settings")
                } label: {
                    Label("User Settings", systemImage: "person.circle")
                }
            }
        }
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
    view_personalBar(path: .constant([]))
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

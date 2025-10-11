//
//  view_Bar.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 22/07/2025.
//

import SwiftUI
import SwiftData

struct view_personalBar: View {
    @Environment(\.modelContext) private var context
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myBarViewModel: MyBarViewModel
    
    @Binding var path: [String]
    
    @State private var presentSheet = false
    
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
            
            if (myBarViewModel.personalBar.userId != userViewModel.currentUser?.id) {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    VStack {
                        Text("No Bar Found")
                            .foregroundStyle(.secondary)
                        Button(action: {
                            Task {
                                await myBarViewModel.getPersonalBar()
                            }
                        }) {
                            Text("Retry")
                                .font(.body)
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Spacer()
                }
                Spacer()
            } else {
                Text("\(userViewModel.currentUser?.username.components(separatedBy: " ").first ?? "My")'s Bar Items")
                    .font(.largeTitle.weight(.bold))
                    .padding(.horizontal, 15)
                
                if myBarViewModel.personalBar.myBarItems.isEmpty {
                    
                    // Center text
                    Spacer()
                    
                    
                    HStack(){
                        Spacer()
                        
                        Text("Bar is Empty")
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                    HStack(){
                        Spacer()
                        
                        // add a quick add with ingredients for my bar
                        Button(action: { presentSheet.toggle() }) {
                            Label("Quick add", systemImage: "arrow.up")
                        }
                        .sheet(isPresented: $presentSheet) {
                            QuickAdd()
                                .environmentObject(myBarViewModel)
                        }
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                } else {
                    barItemList()
                        .environmentObject(myBarViewModel)
                }
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
        .navigationTitle("\(userViewModel.currentUser?.username.components(separatedBy: " ").first ?? "My")'s Bar")
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
        let trimmedName = newItemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        let newItem = MyBarItem(name: trimmedName.lowercased())
        if let selectedCategory = newItemCategory {
            newItem.category = selectedCategory
        } else {
            newItem.assignCategoryBasedOnName()
        }
        
       
            Task {
                await myBarViewModel.addBarItem(newItem)
            }

        newItemName = ""
        newItemCategory = nil
        
    }
}

#Preview {
    // Create an in-memory model container for previews
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MyBar.self, configurations: config)
    let context = container.mainContext
    
    let myBarVM = MyBarViewModel(context: context)
    
    view_personalBar(path: .constant([]))
        .environmentObject({
            let vm = UserViewModel()
            vm.currentUser = LoggedInUser(
                id: UUID(),
                username: "PreviewUser",
                addPermission: false,
                editPermissions: false,
                adminRights: false
            )
            return vm
        }())
        .environmentObject(myBarVM)
}

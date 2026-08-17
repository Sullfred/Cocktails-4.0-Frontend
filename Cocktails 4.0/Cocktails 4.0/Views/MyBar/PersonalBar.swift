//
//  view_Bar.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 22/07/2025.
//

import SwiftUI
import SwiftData

struct PersonalBar: View {
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
                NavigationLink(destination: Notes()) {
                    Label("myBar_guide", systemImage: "book.pages")
                        .font(.headline)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.textPrimary, Color.black.opacity(0.5))
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
                        Text("myBar_no_bar_found")
                            .foregroundStyle(.secondary)
                        Button(action: {
                            Task {
                                await myBarViewModel.GetPersonalBar()
                            }
                        }) {
                            Text("retry")
                                .font(.body)
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Spacer()
                }
                Spacer()
            } else {
                Text("myBar_bar_items\(userViewModel.currentUser?.username.components(separatedBy: " ").first ?? "my")")
                    .font(.largeTitle.weight(.bold))
                    .padding(.horizontal, 15)
                
                if myBarViewModel.personalBar.myBarItems.isEmpty {
                    // Center text
                    Spacer()
                    
                    HStack(){
                        Spacer()
                        
                        Text("myBar_empty")
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                    HStack(){
                        Spacer()
                        
                        // add a quick add with ingredients for my bar
                        Button(action: openQuickAddView) {
                            Label("myBar_quick_add", systemImage: "note.text.badge.plus")
                        }
                        .sheet(isPresented: $presentSheet) {
                            QuickAdd()
                        }
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                } else {
                    barItemList()
                }
            }
            
            if (userViewModel.isLoggedIn) {
                
                Divider()
                
                HStack(alignment: .lastTextBaseline) {
                    VStack(alignment: .leading){
                        Text("myBar_new_item")
                            .font(.callout)
                            .foregroundStyle(Color.textPrimary)
                        TextField(
                            "",
                            text: $newItemName,
                            prompt: Text("myBar_new_item_name")
                                .foregroundStyle(Color.textSecondary)
                        )
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .foregroundStyle(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3))
                        )
                    }
                    
                    VStack(alignment: .trailing){
                        Text("myBar_category")
                            .font(.callout)
                            .foregroundStyle(Color.textPrimary)
                        Picker("myBar_category", selection: $newItemCategory) {
                            Text("myBar_auto_assign").tag(nil as BarItemCategory?)
                            ForEach(BarItemCategory.allCases, id: \.self) { category in
                                Text(category.rawValue.capitalized).tag(category as BarItemCategory?)
                            }
                        }
                    }
                    
                    Button(action: add_item) {
                        Text("add")
                            .frame(minWidth: 25)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .frame(minHeight: 50)
                .padding()
                
            }
        }
        .navigationTitle("\((userViewModel.currentUser?.username.components(separatedBy: " ").first ?? "my"))'s bar")
        .background(Color.background)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    path.append("settings")
                } label: {
                    Label("user_settings", systemImage: "person.circle")
                }
            }
        }
        .tint(Color.textPrimary)
        .alert("error_add", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    func add_item() {
        if (userViewModel.currentUser?.authState == .authenticated) {
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
            
        } else {
            ToastManager.shared.show(style: .warning, message: "login_required")
        }
        
    }
    
    func openQuickAddView() {
        if (userViewModel.isLoggedIn) {
            presentSheet.toggle()
        } else {
            ToastManager.shared.show(style: .warning, message: "login_required")
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
    
    PersonalBar(path: .constant([]))
        .environmentObject({
            let vm = UserViewModel(dependencies: dependencies)
            vm.currentUser = LoggedInUser(
                id: UUID(),
                username: "PreviewUser",
                role: .admin,
                authState: .authenticated
            )
            return vm
        }())
        .environmentObject(myBarVM)
}

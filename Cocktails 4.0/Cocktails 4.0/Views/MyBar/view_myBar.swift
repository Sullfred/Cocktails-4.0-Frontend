//
//  view_Bar.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 22/07/2025.
//

import SwiftUI

import SwiftData

struct view_myBar: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var bars: [MyBar]
    
    @State private var newItemName: String = ""
    @State private var newItemCategory: BarItemCategory? = nil
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    NavigationLink(destination: view_notes()) {
                        Label("Guide", systemImage: "note.text")
                    }
                }
                .padding(.leading, 15)
                
                
                Text("My Bar Items")
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
                        try? modelContext.save()
                        newItemName = ""
                        newItemCategory = nil
                    }
                    .disabled(newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }
            .navigationTitle("My Bar")
            .background(Color.colorSet2)
        }
        .tint(.colorSet4)
    }
}

#Preview {
    view_myBar()
}

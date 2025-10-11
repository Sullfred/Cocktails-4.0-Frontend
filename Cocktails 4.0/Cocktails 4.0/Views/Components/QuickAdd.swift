//
//  QuickAdd.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 08/10/2025.
//

import SwiftUI
import SwiftData

struct QuickAdd: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var myBarViewModel: MyBarViewModel
    
    @Query private var ingredients: [Ingredient]
    
    @State private var quickAddBarItems: [MyBarItem] = []
    @State private var selectedBarItems = [MyBarItem?]()
    
    init() {}
    
    var body: some View {
        VStack(spacing: 10) {
            
            Text("Select items you have at home / usually on hand")
                .font(.footnote)
                .foregroundStyle(Color.secondary)
            
            
            ScrollView{
                LazyVStack(spacing: 20, pinnedViews: [.sectionHeaders]) {
                    ForEach(BarItemCategory.allCases, id: \.self) { category in
                        let itemsInCategory = quickAddBarItems.filter { $0.category == category }.sorted(by: {$0.name < $1.name})
                        Section(header: categoryHeader(category)) {
                            MultiSelectButtonView(itemsInCategory, $selectedBarItems) { item in
                                
                                HStack(alignment: .firstTextBaseline) {
                                    Image(systemName: selectedBarItems.contains(item) ? "checkmark.square.fill" : "square")
                                        .foregroundStyle(selectedBarItems.contains(item) ? .blue : .primary)
                                        .font(.system(size: 25, weight: .light))
                                    
                                    HStack(alignment: .firstTextBaseline) {
                                        Text(item.name.capitalized)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.leading)
                                .frame(height: 35)
                            }
                        }
                    }
                }
            }
            HStack {
                Button {
                    //Do nothing and dismiss
                    dismiss()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: 100)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.colorSet5)
                
                Spacer()
                
                Button {
                    if (!selectedBarItems.isEmpty) {
                        addItems(barItems: selectedBarItems.compactMap(\.self))
                    }
                    
                    dismiss()
                } label: {
                    Text("Confirm")
                        .frame(maxWidth: 100)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.colorSet4)
                .disabled(selectedBarItems.isEmpty)
            }
            .padding(15)
        }
        .padding(20)
        .background(Color.colorSet2)
        .onAppear {
            // Compute top ingredients by frequency (most common ingredient names)
            let nameCounts = Dictionary(grouping: ingredients.map { $0.name.lowercased() }, by: { $0 })
                .mapValues { $0.count }
            
            let topNames = nameCounts.sorted(by: { $0.value > $1.value }).map { $0.key }.prefix(30)
            
            let items = topNames.map { name -> MyBarItem in
                let barItem = MyBarItem(name: name)
                barItem.assignCategoryBasedOnName()
                return barItem
            }
            
            quickAddBarItems = items.sorted { $0.name < $1.name }
        }
    }
}

@ViewBuilder
private func categoryHeader(_ category: BarItemCategory) -> some View {
    HStack {
        Text(category.rawValue.capitalized)
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

private extension QuickAdd {
    func addItems(barItems: [MyBarItem]) {
        barItems.forEach { item in
            Task {
                await myBarViewModel.addBarItem(item)
            }
        }
    }
}

#Preview {
    // Create an in-memory model container for previews
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MyBar.self, configurations: config)
    let context = container.mainContext
    
    let myBarVM = MyBarViewModel(context: context)
    
    QuickAdd()
        .environmentObject(myBarVM)
}

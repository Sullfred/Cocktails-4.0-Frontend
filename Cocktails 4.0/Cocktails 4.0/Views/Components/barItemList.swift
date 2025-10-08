//
//  view_barItemList.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 25/09/2025.
//

import SwiftUI
import SwiftData

struct barItemList: View {
    @EnvironmentObject var myBarViewModel: MyBarViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20, pinnedViews: [.sectionHeaders]) {
                ForEach(BarItemCategory.allCases, id: \.self) { category in
                    let itemsInCategory = (myBarViewModel.personalBar.myBarItems).filter { $0.category == category }.sorted(by: {$0.name < $1.name})
                    Section(header: categoryHeader(category)) {
                        if itemsInCategory.isEmpty {
                            Text("No items in \(category.rawValue.capitalized).")
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                        } else {
                            ForEach(itemsInCategory) { item in
                                barItemRow(barItem: item)
                                    .environmentObject(myBarViewModel)
                            }
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
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

#Preview {
    // Create an in-memory model container for previews
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MyBar.self, configurations: config)
    let context = container.mainContext
    
    let myBarVM = MyBarViewModel(context: context)
    
    barItemList()
        .environmentObject(myBarVM)
}

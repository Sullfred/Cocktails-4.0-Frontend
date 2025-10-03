//
//  view_barItemList.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 25/09/2025.
//

import SwiftUI

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
    }


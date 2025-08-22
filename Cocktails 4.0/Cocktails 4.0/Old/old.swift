//
//  old.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/07/2025.
//

/*
 @Environment(\.modelContext) private var modelContext
 @Query private var items: [Item]
 
 var body: some View {
 NavigationSplitView {
 List {
 ForEach(items) { item in
 NavigationLink {
 Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
 } label: {
 Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
 }
 }
 .onDelete(perform: deleteItems)
 }
 .toolbar {
 ToolbarItem(placement: .navigationBarTrailing) {
 EditButton()
 }
 ToolbarItem {
 Button(action: addItem) {
 Label("Add Item", systemImage: "plus")
 }
 }
 }
 } detail: {
 Text("Select an item")
 }
 }
 
 private func addItem() {
 withAnimation {
 let newItem = Item(timestamp: Date())
 modelContext.insert(newItem)
 }
 }
 
 private func deleteItems(offsets: IndexSet) {
 withAnimation {
 for index in offsets {
 modelContext.delete(items[index])
 }
 }
 }
 
 */


/*
ForEach(newCocktailIngredients) { _ingredient in
    HStack {
        Text(_ingredient.volume, format: .number.precision(.fractionLength(2)))
            .frame(width: 45.0)
        Text(_ingredient.unit.localizedName)
            .frame(width: 40.0)
        Text(_ingredient.name.capitalized)

        Spacer()

        Divider()

        Button(action: {
            newCocktailIngredients.removeAll { $0.id == _ingredient.id }
        }) {
            Image(systemName: "minus.circle.fill")
                .foregroundStyle(.colorSet5)
        }
    }
    .buttonStyle(PlainButtonStyle())
}
 */

//
//  view_deletedCocktails.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 28/08/2025.
//

import SwiftUI
import SwiftData

struct view_deletedCocktails: View {
    @Environment(\.modelContext) private var context
    @Query private var myBars: [MyBar]
    
    @State var selectedCocktails = [DeletedCocktail?]()

    var body: some View {
        ZStack{
            if let myBar = myBars.first {
                if myBar.deletedCocktails.isEmpty {
                    Text("No deleted cocktails")
                        .foregroundStyle(.secondary)
                } else {
                    VStack {
                        Text("Deleted Cocktails")
                            .font(.title)
                            .padding(.bottom, 15)
                
                        MultiSelectButtonView(myBar.deletedCocktails, $selectedCocktails) { item in
                            
                            HStack(alignment: .center) {
                                Image(systemName: selectedCocktails.contains(item) ? "checkmark.square.fill" : "square")
                                    .foregroundStyle(selectedCocktails.contains(item) ? .blue : .primary)
                                    .font(.system(size: 30, weight: .light))
                                
                                HStack(alignment: .firstTextBaseline) {
                                    VStack(alignment: .leading) {
                                        Text(item.name.capitalized)
                                        if !item.creator.isEmpty {
                                            Text("By \(item.creator.capitalized)")
                                                .font(.subheadline)
                                                .foregroundStyle(Color.secondary)
                                        } else {
                                            Text("By Unknown")
                                                .font(.subheadline)
                                                .foregroundStyle(Color.secondary)
                                        }
                                    }
                                    Spacer()
                                    Text("Deleted: \(item.date, format: .dateTime.day().month().year())")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .frame(width: 95)
                                }
                            }
                            .padding(.leading)
                            .padding(.trailing)
                            .frame(height: 55)
                        }
                        Spacer()
                        Text("Selected: \(selectedCocktails.map { $0!.name.capitalized }.joined(separator: ", "))")
                        Button(action: undoDeletes) {
                            Label("Undo Deletes", systemImage: "arrow.uturn.backward")
                        }
                        .disabled(selectedCocktails.isEmpty)
                        .tint(Color.colorSet5)
                    }
                    .padding()
                }
            } else {
                Text("No deleted cocktails")
                    .foregroundStyle(.secondary)
            }
        }
        .containerRelativeFrame([.horizontal, .vertical])
        .background(Color.colorSet2)
        /*
        .task {
            context.insert(MyBar(deletedCocktails: [DeletedCocktail(id: "1id", name: "Negroni", creator: "anders erickson"), DeletedCocktail(id: "2id", name: "Whiskey sour", creator: ""), DeletedCocktail(id: "3id", name: "Pisco sour", creator: "anders erickson")]))
        }
        */
    }
}

private extension view_deletedCocktails {
    func undoDeletes() {
        if let myBar = myBars.first {
            selectedCocktails.forEach { item in
                if let index = myBar.deletedCocktails.firstIndex(where: {$0.id == item?.id}) {
                    myBar.deletedCocktails.remove(at: index)
                }
            }
            selectedCocktails = []
        }
    }
}

#Preview {
    view_deletedCocktails()
        .modelContainer(for: MyBar.self, inMemory: true)
}

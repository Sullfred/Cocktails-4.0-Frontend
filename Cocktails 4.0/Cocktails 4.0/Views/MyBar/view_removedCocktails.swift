//
//  view_deletedCocktails.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 28/08/2025.
//

import SwiftUI
import SwiftData

struct view_removedCocktails: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject var myBarViewModel: MyBarViewModel
    
    @Query private var myBars: [MyBar]
    
    @State var selectedCocktails = [RemovedCocktail?]()
    
    var body: some View {
        ZStack{
            if myBarViewModel.personalBar.removedCocktails.isEmpty {
                Text("No Removed cocktails")
                    .foregroundStyle(.secondary)
            } else {
                ScrollView {
                    MultiSelectButtonView(myBarViewModel.personalBar.removedCocktails, $selectedCocktails) { item in
                        
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
                        Label("Undo Removes", systemImage: "arrow.uturn.backward")
                    }
                    .disabled(selectedCocktails.isEmpty)
                    .tint(Color.colorSet5)
                }
                .padding()
                .navigationTitle("Removed Cocktails")
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

private extension view_removedCocktails {
    func undoDeletes() {
            selectedCocktails.forEach { item in
                if let removed = item {
                    Task {
                        await myBarViewModel.deleteRemoved(removed)
                    }
                }
            }
            selectedCocktails = []
    }
}

#Preview {
    view_removedCocktails()
        .modelContainer(for: MyBar.self, inMemory: true)
}

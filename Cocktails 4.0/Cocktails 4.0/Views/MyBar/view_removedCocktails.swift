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
                                Text("Removed: \(item.date, format: .dateTime.day().month().year())")
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
                        Label("Undo Remove", systemImage: "arrow.uturn.backward")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedCocktails.isEmpty)
                    .tint(Color.colorSet4)
                }
                .padding()
                .navigationTitle("Removed Cocktails")
            }
            
        }
        .containerRelativeFrame([.horizontal, .vertical])
        .background(Color.colorSet2)
    }
}

private extension view_removedCocktails {
    func undoDeletes() {
        var deletedCocktails: [RemovedCocktail] = []
        
        selectedCocktails.forEach { item in
            if let removed = item {
                deletedCocktails.append(removed)
            }
        }
        if !deletedCocktails.isEmpty {
            Task {
                await myBarViewModel.deleteRemoved(deletedCocktails)
            }
            selectedCocktails = []
        }
    }
}

#Preview {
    // Create an in-memory model container for previews
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MyBar.self, configurations: config)
    let context = container.mainContext
    
    let myBarVM = MyBarViewModel(context: context)
    
    view_removedCocktails()
        .modelContainer(for: MyBar.self, inMemory: true)
        .environmentObject(myBarVM)
}

//
//  view_deletedCocktails.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 28/08/2025.
//

import SwiftUI
import SwiftData

struct HiddenCocktails: View {
    @EnvironmentObject var myBarViewModel: MyBarViewModel
    @State var selectedCocktails = [HiddenCocktail?]()
    
    var body: some View {
        ZStack{
            if myBarViewModel.personalBar.removedCocktails.isEmpty {
                Text("no_removed_cocktails")
                    .foregroundStyle(.secondary)
            } else {
                ScrollView {
                    MultiSelectButtonView(myBarViewModel.personalBar.removedCocktails, $selectedCocktails) { item in
                        
                        HStack(alignment: .center) {
                            Image(systemName: selectedCocktails.contains(item) ? "checkmark.square.fill" : "square")
                                .foregroundStyle(selectedCocktails.contains(item) ? .blue : .primary)
                                .font(.system(size: 30, weight: .light))
                            
                            HStack(alignment: .firstTextBaseline) {
                                RemovedBy(item: item)
                                Spacer()
                                RemovedDate(item: item)
                                    .frame(width: 95)
                            }
                        }
                        .padding(.leading)
                        .padding(.trailing)
                        .frame(height: 55)
                    }
                    Spacer()
                    Text("selected\(selectedCocktails.map { $0!.name.capitalized }.joined(separator: ", "))")
                    Button(action: undoDeletes) {
                        Label("cocktails_removed_undo", systemImage: "arrow.uturn.backward")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedCocktails.isEmpty)
                    .tint(Color.textPrimary)
                }
                .padding()
                .navigationTitle("cocktails_removed")
            }
            
        }
        .containerRelativeFrame([.horizontal, .vertical])
        .background(Color.background)
    }
    
    func undoDeletes() {
        var deletedCocktails: [HiddenCocktail] = []
        
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
    
    let dependencies = AppDependencies(context: context)
    let myBarVM = MyBarViewModel(dependencies: dependencies)
    
    HiddenCocktails()
        .modelContainer(for: MyBar.self, inMemory: true)
        .environmentObject(myBarVM)
}

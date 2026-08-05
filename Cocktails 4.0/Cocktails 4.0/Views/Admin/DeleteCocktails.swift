//
//  SwiftUIView.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 27/10/2025.
//

import SwiftUI
import SwiftData

struct DeleteCocktails: View {
    @EnvironmentObject var adminViewModel: AdminViewModel
    @EnvironmentObject var myBarViewModel: MyBarViewModel
    
    @State var selectedCocktails = [HiddenCocktail?]()
    
    var body: some View {
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
                Button {
                    hideCocktails()
                } label: {
                    if adminViewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else if adminViewModel.isSuccess {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("cocktails_removed_delete_count\(selectedCocktails.count)")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.textPrimary)
                .disabled(selectedCocktails.isEmpty || adminViewModel.isLoading)
                
            }
            .padding()
        }
    }
    
    func hideCocktails() {
        var deletedCocktails: [HiddenCocktail] = []
        var cocktailIds: [String] = []
        
        selectedCocktails.forEach { item in
            if let removed = item {
                deletedCocktails.append(removed)
                cocktailIds.append(removed.cocktailId)
            }
        }

        if !cocktailIds.isEmpty {
            Task {
                let success = await adminViewModel.deleteCocktails(cocktailIds: cocktailIds)
                if success {
                    adminViewModel.isSuccess = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            adminViewModel.isSuccess = false
                        }
                    }
                    await myBarViewModel.deleteRemoved(deletedCocktails)
                    selectedCocktails = []
                }
            }
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
    
    DeleteCocktails()
        .environmentObject(AdminViewModel(dependencies: dependencies))
        .environmentObject(myBarVM)
}

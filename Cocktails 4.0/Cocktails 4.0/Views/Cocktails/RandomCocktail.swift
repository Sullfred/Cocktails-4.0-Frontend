//
//  RandomCocktail.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 28/06/2026.
//

import Foundation
import SwiftUI
import SwiftData

struct RandomCocktail: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var cocktailViewModel: CocktailViewModel
    @EnvironmentObject var myBarViewModel: MyBarViewModel

    @State private var toggleCreatableCocktails: Bool = false
    @State private var randomCocktail: Cocktail?
    @State private var isRandomizing = false

    private let searchManager = SearchManager.shared

    private var availableCocktails: [Cocktail] {
        let cocktails = cocktailViewModel.fetchLocalCocktails()

        let availableIngredients = Set(
            myBarViewModel.personalBar.myBarItems.map { $0.name }
        )

        if toggleCreatableCocktails {
            return cocktails.filter {
                searchManager.canCraft($0, using: availableIngredients)
            }
        }

        return cocktails
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                VStack(spacing: 8) {
                    Text("🍸")
                        .font(.system(size: 60))

                    Text("random_title")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("random_subtitle")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)

                // Cocktail card or placeholder card
                VStack {
                    if let cocktail = randomCocktail {
                        CocktailCard(cocktail: cocktail)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        CocktailCardPlaceholder()
                    }
                }
                .padding(.vertical, 20)

                VStack(spacing: 20) {
                    Button {
                        randomizeCocktail()
                    } label: {
                        Text(isRandomizing ? "random_choosing" : (randomCocktail == nil ? "random_try1" : "random_try2")
                        )
                            .fontWeight(.black)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                    }
                    .disabled(isRandomizing)

                    if userViewModel.isLoggedIn {
                        Toggle(isOn: $toggleCreatableCocktails) {
                            Text("random_creatables")
                                .font(.subheadline)
                        }
                        .padding(.horizontal)
                        .controlSize(.small)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .animation(.spring(), value: randomCocktail?.id)
        .background(Color.background)
    }

    func randomizeCocktail() {
        guard !isRandomizing else {
            return
        }

        let cocktails = availableCocktails
        guard !cocktails.isEmpty else {
            randomCocktail = nil
            return
        }

        isRandomizing = true

        Task { @MainActor in
            let numberOfCycles = 18

            for index in 0..<numberOfCycles {
                let delay = 0.05 + (Double(index) / Double(numberOfCycles)) * 0.12

                try? await Task.sleep(for: .seconds(delay))

                withAnimation(.easeInOut(duration: 0.08)) {
                    randomCocktail = cocktails.randomElement()
                }
            }

            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                randomCocktail = cocktails.randomElement()
                isRandomizing = false
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
    let cocktailVM = CocktailViewModel(dependencies: dependencies)
    
    RandomCocktail()
        .environmentObject({
            let vm = UserViewModel(dependencies: dependencies)
            vm.currentUser = LoggedInUser(
                id: UUID(),
                username: "Daniel Vang Kleist",
                role: .admin,
                authState: .authenticated
            )
            return vm
        }())
        .environmentObject(cocktailVM)
}

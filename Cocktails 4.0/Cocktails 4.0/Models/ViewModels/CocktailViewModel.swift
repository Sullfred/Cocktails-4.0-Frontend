//
//  CocktailsViewModel.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 27/09/2025.
//

/*
import Foundation
import SwiftUI
import SwiftData

@MainActor
final class CocktailViewModel: ObservableObject {
    @Published var cocktails: [Cocktail] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = CocktailService.shared
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        loadLocal()
    }

    func loadLocal() {
        cocktails = (try? context.fetch(FetchDescriptor<Cocktail>())) ?? []
    }

    func sync() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let dtos = try await service.fetchCocktails()
            for dto in dtos {
                let cocktail = Cocktail(
                    name: dto.name,
                    creator: dto.creator,
                    style: dto.style,
                    ingredients: dto.ingredients.map { Ingredient(volume: $0.volume, unit: $0.unit, name: $0.name) },
                    comment: dto.comment,
                    image: nil,
                    imageURL: dto.imageURL,
                    cocktailCategory: dto.cocktailCategory
                )
                context.insert(cocktail)
            }
            try context.save()
            loadLocal()
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
        }
    }
}
*/

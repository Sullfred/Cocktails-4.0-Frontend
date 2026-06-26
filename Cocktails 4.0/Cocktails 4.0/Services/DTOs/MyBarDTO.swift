//
//  MyBarDTO.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 27/09/2025.
//


import Foundation

// MARK: - DTOs

struct MyBarDTO: Codable, Identifiable {
    var id: UUID
    var userId: UUID
    var barItems: [MyBarItemDTO]
    var favoriteCocktails: [String]
    var hiddenCocktails: [HiddenCocktailDTO]
}

struct MyBarItemDTO: Codable {
    var id: UUID
    var name: String
    var category: BarItemCategory
}

struct HiddenCocktailDTO: Codable, Identifiable {
    var id: UUID
    var cocktailId: String
    var name: String
    var creator: String
    var date: Date
}

// MARK: - Conversion Extensions
// MyBar
extension MyBarDTO {
    init(from model: MyBar) {
        self.id = model.id
        self.userId = model.userId ?? UUID()
        self.barItems = model.myBarItems.map { MyBarItemDTO(from: $0) }
        self.favoriteCocktails = model.favoriteCocktails
        self.hiddenCocktails = model.removedCocktails.map { HiddenCocktailDTO(from: $0) }
    }
}

extension MyBar {
    convenience init(from dto: MyBarDTO) {
        self.init(
            userId: dto.userId,
            myBarItems: dto.barItems.map { MyBarItem(from: $0) },
            favoriteCocktails: dto.favoriteCocktails,
            deletedCocktails: dto.hiddenCocktails.map {HiddenCocktail(from: $0)}
        )
    }
}

// Bar item
extension MyBarItemDTO {
    init(from model: MyBarItem) {
        self.id = model.id
        self.name = model.name
        self.category = model.category
    }
}

extension MyBarItem {
    convenience init(from dto: MyBarItemDTO) {
        self.init(
            id: dto.id,
            name: dto.name,
            category: dto.category
        )
    }
}

// Deleted cocktail
extension HiddenCocktailDTO {
    init(from model: HiddenCocktail) {
        self.id = model.id
        self.cocktailId = model.cocktailId
        self.name = model.name
        self.creator = model.creator
        self.date = model.date
    }
}

extension HiddenCocktail {
    init(from dto: HiddenCocktailDTO) {
        self.init(
            cocktailId: dto.cocktailId,
            name: dto.name,
            creator: dto.creator,
            date: dto.date
        )
    }
}

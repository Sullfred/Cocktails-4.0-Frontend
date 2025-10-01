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
    var deletedCocktails: [RemovedCocktailDTO]
}

struct MyBarItemDTO: Codable {
    var name: String
    var category: String // String representation of BarItemCategory
}

struct RemovedCocktailDTO: Codable, Identifiable {
    var id: String
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
        self.deletedCocktails = model.removedCocktails.map { RemovedCocktailDTO(from: $0) }
    }
}

extension MyBar {
    convenience init(from dto: MyBarDTO) {
        self.init(
            userId: dto.userId,
            myBarItems: dto.barItems.map { MyBarItem(from: $0) },
            favoriteCocktails: dto.favoriteCocktails,
            deletedCocktails: dto.deletedCocktails.map {RemovedCocktail(from: $0)}
        )
    }
}

// Bar item
extension MyBarItemDTO {
    init(from model: MyBarItem) {
        self.name = model.name
        self.category = model.category.rawValue
    }
}

extension MyBarItem {
    convenience init(from dto: MyBarItemDTO) {
        self.init(
            name: dto.name,
            category: BarItemCategory(rawValue: dto.category) ?? .other
        )
    }
}

// Deleted cocktail
extension RemovedCocktailDTO {
    init(from model: RemovedCocktail) {
        self.id = model.id
        self.name = model.name
        self.creator = model.creator
        self.date = model.date
    }
}

extension RemovedCocktail {
    init(from dto: RemovedCocktailDTO) {
        self.init(
            id: dto.id,
            name: dto.name,
            creator: dto.creator,
            date: dto.date
        )
    }
}

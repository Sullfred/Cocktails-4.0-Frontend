//
//  MockMyBarService.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 16/08/2026.
//

@testable import Cocktails_4_0
import Foundation

final class MockMyBarService: MyBarService {
    var addedItems: [[MyBarItemDTO]] = []
    var deletedItemIds: [[UUID]] = []
    var addedFavorites: [[UUID]] = []
    var deletedFavorites: [[UUID]] = []
    var addedHiddenCocktails: [[HiddenCocktailDTO]] = []
    var deletedHiddenCocktailIds: [[UUID]] = []

    override func addBarItem(_ payloads: [MyBarItemDTO]) async throws {
        addedItems.append(payloads)
    }

    override func deleteBarItems(_ payloads: [UUID]) async throws {
        deletedItemIds.append(payloads)
    }

    override func addFavorites(_ cocktailIDs: [UUID]) async throws {
        addedFavorites.append(cocktailIDs)
    }

    override func deleteFavorites(_ cocktailIDs: [UUID]) async throws {
        deletedFavorites.append(cocktailIDs)
    }

    override func addHiddenCocktail(_ payloads: [HiddenCocktailDTO]) async throws {
        addedHiddenCocktails.append(payloads)
    }

    override func deleteRemoved(_ payloads: [UUID]) async throws {
        deletedHiddenCocktailIds.append(payloads)
    }
}

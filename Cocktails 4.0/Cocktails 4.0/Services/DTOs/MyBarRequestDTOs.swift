import Foundation

struct RemoveBarItemsDTO: Codable {
    let itemIds: [UUID]
}

struct AddFavoritesDTO: Codable {
    let itemIds: [UUID]
}

struct RemoveFavoritesDTO: Codable {
    let itemIds: [UUID]
}

struct RemoveHiddenCocktailsDTO: Codable {
    let itemIds: [UUID]
}

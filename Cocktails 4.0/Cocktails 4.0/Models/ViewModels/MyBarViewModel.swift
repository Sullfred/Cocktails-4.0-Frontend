//
//  MyBarViewModel.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 27/09/2025.
//

import Foundation
import SwiftUI
import SwiftData
import KeychainSwift

@MainActor
final class MyBarViewModel: ObservableObject {
    @Published var myBarItems: [MyBarItem] = []
    @Published var favoriteCocktails: [String] = []
    @Published var deletedCocktails: [RemovedCocktail] = []
    @Published var errorMessage: String?

    private let service: MyBarService
    private let context: ModelContext
    private let pendingActionService: PendingActionService

    init(context: ModelContext) {
        self.context = context
        self.service = MyBarService(context: context)
        self.pendingActionService = PendingActionService(context: context)
    }

    func getPersonalBar() async {
        do {
            // get userToken
            let keychain = KeychainSwift()
            guard let token = keychain.get("userToken")
            else {
                return
            }
            
            try await service.fetchMyBar(context: context, userToken: token)
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
        }
    }

    func addBarItem(_ barItem: MyBarItem) async {
        // update local state
        myBarItems.append(barItem)
        
        do {
            // For testing purpose
            pendingActionService.clearAll()
            // Add item to pending queue
            let dto = MyBarItemDTO(from: barItem)
            pendingActionService.addAction(.addBarItem, payload: dto)
            
            // get userToken
            let keychain = KeychainSwift()
            guard let token = keychain.get("userToken")
            else {
                return
            }
            // Attempt to sync with database
            try await service.syncAddBarItem(userToken: token)
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
        }
    }

    func deleteBarItem(_ item: MyBarItem) async {
        // update local state
        myBarItems.removeAll { $0.id == item.id }
        
        do {
            // Add item to pending queue
            pendingActionService.addAction(.deleteBarItem, payload: MyBarItemDTO(from: item))
            
            // get userToken
            let keychain = KeychainSwift()
            guard let token = keychain.get("userToken")
            else {
                return
            }
            
            // Attempt to sync with database
            try await service.syncDeleteBarItem(userToken: token)
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
        }
    }

    func addFavorite(cocktailID: String) async {
        // update local state
        if !favoriteCocktails.contains(cocktailID) {
            favoriteCocktails.append(cocktailID)
        }
        
        do {
            // Add item to pending queue
            pendingActionService.addAction(.addFavorite, payload: cocktailID)
            
            // get userToken
            let keychain = KeychainSwift()
            guard let token = keychain.get("userToken")
            else {
                return
            }
            
            // Attempt to sync with database
            try await service.syncAddFavorites(userToken: token)
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
        }
    }

    func deleteFavorite(cocktailID: String) async {
        // update local state
        favoriteCocktails.removeAll { $0 == cocktailID }
        
        do {
            // Add item to pending queue
            pendingActionService.addAction(.deleteFavorite, payload: cocktailID)
            
            // get userToken
            let keychain = KeychainSwift()
            guard let token = keychain.get("userToken")
            else {
                return
            }
            
            // Attempt to sync with database
            try await service.syncDeleteFavorites(userToken: token)
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
        }
    }

    func addRemoved(_ deleted: RemovedCocktail) async {
        // update local state
        deletedCocktails.append(deleted)
        
        do {
            // Add item to pending queue
            pendingActionService.addAction(.addRemoved, payload: RemovedCocktailDTO(from: deleted))
            
            // get userToken
            let keychain = KeychainSwift()
            guard let token = keychain.get("userToken")
            else {
                return
            }
            
            // Attempt to sync with database
            try await service.syncAddRemoves(userToken: token)
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
        }
    }

    func deleteRemoved(_ deleted: RemovedCocktail) async {
        // update local state
        deletedCocktails.removeAll { $0.id == deleted.id }
        
        do {
            // Add item to pending queue
            pendingActionService.addAction(.deleteRemoved, payload: RemovedCocktailDTO(from: deleted))
            
            // get userToken
            let keychain = KeychainSwift()
            guard let token = keychain.get("userToken")
            else {
                return
            }
            
            // Attempt to sync with database
            try await service.syncDeleteRemoves(userToken: token)
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
        }
    }
}

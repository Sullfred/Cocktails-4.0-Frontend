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
    @Published var personalBar = MyBar()
    @Published var errorMessage: String?

    private let service: MyBarService
    private let context: ModelContext
    private let pendingActionService: PendingActionService

    init(context: ModelContext) {
        self.context = context
        self.service = MyBarService(context: context)
        self.pendingActionService = PendingActionService(context: context)
        
        fetchData()
    }
    
    // Get the local personal bar, if the user is logged in we get the users bar, else the default bar
    func fetchData() {
        do {
            let bars = try context.fetch(FetchDescriptor<MyBar>())
            
            // Try to get logged in user and make the personal bar the users bar if it exists
            if let data = UserDefaults.standard.data(forKey: "loggedInUser"),
               let loggedInUser = try? JSONDecoder().decode(LoggedInUser.self, from: data) {
                
                if let userBar = bars.first(where: { $0.userId == loggedInUser.id }) {
                    personalBar = userBar
                } else if let firstBar = bars.first {
                    personalBar = firstBar
                }
                
            } else if let firstBar = bars.first {
                personalBar = firstBar
            }
            
        } catch {
            ErrorHandler.handle(ErrorOutput.customError(message: "No Bar found"))
        }
    }
    
    func changeToGuestBar() {
        do {
            let bars = try context.fetch(FetchDescriptor<MyBar>())
            
            if let firstBar = bars.first {
                if let userBar = bars.first(where: {$0.userId == personalBar.userId}) {
                    personalBar = firstBar
                    context.delete(userBar)
                    try context.save()
                }
            }
            
        } catch {
            ErrorHandler.handle(ErrorOutput.customError(message: "No Bar found"))
        }
    }

    func getPersonalBar() async {
        do {
            // get userToken
            let keychain = KeychainSwift()
            guard let token = keychain.get("userToken")
            else {
                return
            }
            
            let userBar = try await service.fetchMyBar(context: context, userToken: token)
            personalBar = userBar
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
        }
    }

    func addBarItem(_ barItem: MyBarItem) async {
        // update local state
        do {
            personalBar.myBarItems.append(barItem)
            try context.save()
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
        }
        
        do {
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

    func deleteBarItem(_ barItem: MyBarItem) async {
        // update local state
        do {
            personalBar.myBarItems.removeAll { $0.id == barItem.id }
            try context.save()
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
        }
        
        do {
            // Add item to pending queue
            let dto = MyBarItemDTO(from: barItem)
            pendingActionService.addAction(.deleteBarItem, payload: dto)
            
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
        if !personalBar.favoriteCocktails.contains(cocktailID) {
            do {
                personalBar.favoriteCocktails.append(cocktailID)
                try context.save()
            } catch {
                errorMessage = ErrorHandler.normalize(error).localizedDescription
            }
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
        do {
            personalBar.favoriteCocktails.removeAll{ $0 == cocktailID }
            try context.save()
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
        }
        
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

    func addRemoved(_ removed: RemovedCocktail) async {
        // update local state
        do {
            personalBar.removedCocktails.append(removed)
            try context.save()
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
        }
        
        do {
            // Add item to pending queue
            let dto = RemovedCocktailDTO(from: removed)
            pendingActionService.addAction(.addRemoved, payload: dto)
            
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

    func deleteRemoved(_ removed: RemovedCocktail) async {
        // update local state
        do {
            personalBar.removedCocktails.removeAll{ $0.id == removed.id }
            try context.save()
        } catch {
            errorMessage = ErrorHandler.normalize(error).localizedDescription
        }
        
        do {
            // Add item to pending queue
            let dto = RemovedCocktailDTO(from: removed)
            pendingActionService.addAction(.deleteRemoved, payload: dto)
            
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

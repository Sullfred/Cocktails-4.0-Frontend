//
//  MyBarViewModel.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 27/09/2025.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
final class MyBarViewModel: ObservableObject {
    @Published var personalBar: MyBar = .empty
    @Published var isSyncing: Bool = false
    
    private let dependencies: AppDependencies
    
    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }
    
    func loadLocalBar() async {
        do {
            if let user = try UserSessionStore.shared.getUser() {
                let targetUserId: UUID = user.id
                let descriptor = FetchDescriptor<MyBar>(
                    predicate: #Predicate<MyBar> { bar in
                        bar.userId == targetUserId
                    }
                )
                
                if let bar = try dependencies.contexCoordinator.fetchOne(descriptor) {
                    personalBar = bar
                }
            }
        } catch {
            ErrorHandler.handle(error)
        }
    }
    
    func GetPersonalBar() async {
        isSyncing = true
        
        defer {
            isSyncing = false
        }
        
        do {
            personalBar = try await dependencies.myBarService.fetchMyBar()
            try dependencies.contexCoordinator.insert(personalBar)
        } catch {
            ErrorHandler.handle(error)
        }
    }
    
    // Bar Items
    func addBarItem(_ item: MyBarItem) async {
        do {
            try dependencies.contexCoordinator.performBatch {
                personalBar.myBarItems.append(item)
            }
            queueAdd(item)
        } catch {
            ErrorHandler.handle(error)
        }
    }
    
    func addMultipleBarItems(_ items: [MyBarItem]) {
        do {
            try dependencies.contexCoordinator.performBatch {
                items.forEach { item in
                    personalBar.myBarItems.append(item)
                    queueAdd(item)
                }
            }
        } catch {
            ErrorHandler.handle(error)
        }
    }
    
    
    func deleteBarItem(_ item: MyBarItem) async {
        do {
            try dependencies.contexCoordinator.performBatch {
                personalBar.myBarItems.removeAll { $0.id == item.id }
            }
            queueDelete(item)
        } catch {
            ErrorHandler.handle(error)
        }
    }
    
    // Favorites
    func addFavorite(_ id: String) async {
        if !personalBar.favoriteCocktails.contains(id) {
            do {
                try dependencies.contexCoordinator.performBatch {
                    personalBar.favoriteCocktails.append(id)
                }
                queueFavoriteAdd(id)
            } catch {
                ErrorHandler.handle(error)
            }
        }
    }
    
    func deleteFavorite(_ id: String) async {
        do {
            try dependencies.contexCoordinator.performBatch {
                
                personalBar.favoriteCocktails.removeAll { $0 == id }
            }
            queueFavoriteDelete(id)
        } catch {
            ErrorHandler.handle(error)
        }
    }
    
    // Removed cocktails
    func addRemoved(_ item: RemovedCocktail) async {
        do {
            try dependencies.contexCoordinator.performBatch {
                
                personalBar.removedCocktails.append(item)
            }
            queueRemovedAdd(item)
        } catch {
            ErrorHandler.handle(error)
        }
    }
    
    func deleteRemoved(_ items: [RemovedCocktail]) async {
        do {
            try dependencies.contexCoordinator.performBatch {
                for item in items {
                    personalBar.removedCocktails.removeAll { $0.id == item.id }
                    queueRemovedDelete(item)
                }
            }
        } catch {
            ErrorHandler.handle(error)
        }
    }
    
    // Queue helpers for syncing items later
    private func queueAdd(_ item: MyBarItem) {
        let dto = MyBarItemDTO(from: item)
        do {
            try dependencies.pendingActionService.addAction(.addBarItem, payload: dto)
        } catch {
            ErrorHandler.handle(error)
        }
    }
    
    private func queueDelete(_ item: MyBarItem) {
        let dto = MyBarItemDTO(from: item)
        do{
            try dependencies.pendingActionService.addAction(.deleteBarItem, payload: dto)
        } catch {
            ErrorHandler.handle(error)
        }
    }
    
    private func queueFavoriteAdd(_ id: String) {
        do {
            try dependencies.pendingActionService.addAction(.addFavorite, payload: id)
        } catch {
            ErrorHandler.handle(error)
        }
    }
    
    private func queueFavoriteDelete(_ id: String) {
        do {
            try dependencies.pendingActionService.addAction(.deleteFavorite, payload: id)
        } catch {
            ErrorHandler.handle(error)
        }
    }
    
    private func queueRemovedAdd(_ item: RemovedCocktail) {
        let dto = RemovedCocktailDTO(from: item)
        do {
            try dependencies.pendingActionService.addAction(.addRemoved, payload: dto)
        } catch {
            ErrorHandler.handle(error)
        }
    }
    
    private func queueRemovedDelete(_ item: RemovedCocktail) {
        let dto = RemovedCocktailDTO(from: item)
        do {
            try dependencies.pendingActionService.addAction(.deleteRemoved, payload: dto)
        } catch {
            ErrorHandler.handle(error)
        }
    }
}

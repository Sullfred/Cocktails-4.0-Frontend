//
//  AppDependencies.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 19/06/2026.
//

import Foundation
import SwiftData

@MainActor
final class AppDependencies: ObservableObject {
    let cocktailService: CocktailService
    let myBarService: MyBarService
    let imageService: ImageService
    let userService: UserService
    let adminService: AdminService

    let pendingActionService: PendingActionService
    let pendingActionCoordinator: PendingActionCoordinator
    let syncCoordinator: SyncCoordinator
    let contexCoordinator: ContextCoordinator

    init(context: ModelContext) {
        let _imageService = ImageService()
        let _cocktailService = CocktailService(imageService: _imageService)
        let _myBarService = MyBarService()
        let _userService = UserService()
        let _adminService = AdminService()

        let _processors: [any PendingActionProcessor] = [
            CocktailsPendingActionProcessor(
                cocktailService: _cocktailService
            ),
            MyBarPendingActionProcessor(
                myBarService: _myBarService
            )
        ]

        let _pendingActionService = PendingActionService(context: context)
        
        let _pendingActionCoordinator = PendingActionCoordinator(pendingActionService: _pendingActionService, processors: _processors)
        let _syncCoordinator = SyncCoordinator(context: context)
        let _contextCoordinator = ContextCoordinator(context: context)

        self.imageService = _imageService
        self.cocktailService = _cocktailService
        self.myBarService = _myBarService
        self.userService = _userService
        self.adminService = _adminService
        self.pendingActionService = _pendingActionService
        self.pendingActionCoordinator = _pendingActionCoordinator
        self.syncCoordinator = _syncCoordinator
        self.contexCoordinator = _contextCoordinator
    }
}

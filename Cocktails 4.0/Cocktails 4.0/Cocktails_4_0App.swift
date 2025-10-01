//
//  Cocktails_4_0App.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 22/07/2025.
//

import SwiftUI
import SwiftData

@main
struct Cocktails_4_0App: App {
    @StateObject private var sharedModelContainer = ModelContainerObservable()
    @StateObject private var cocktailService = CocktailService.shared
    
    @StateObject private var toastManager = ToastManager.shared


    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(toastManager)
                .toastView(toast: $toastManager.toast)
                .task {
                    let modelContext = sharedModelContainer.container.mainContext
                    do {
                        let existingBars = try modelContext.fetch(FetchDescriptor<MyBar>())
                        if existingBars.isEmpty {
                            let newBar = MyBar()
                            modelContext.insert(newBar)
                            try modelContext.save()
                        }
                        
                        if await cocktailService.checkServerConnection() {
                            await cocktailService.syncPendingUploads(context: modelContext)
                            await cocktailService.syncPendingUpdates(context: modelContext)
                            await cocktailService.fetchCocktails(context: modelContext)
                        }
                    } catch {
                        print("Error in startup tasks: \(error)")
                    }
                }
        }
        .modelContainer(sharedModelContainer.container)
    }
}

// Observable wrapper for ModelContainer
class ModelContainerObservable: ObservableObject {
    let container: ModelContainer
    init() {
        let schema = Schema([
            Cocktail.self,
            MyBar.self,
            PendingAction.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}

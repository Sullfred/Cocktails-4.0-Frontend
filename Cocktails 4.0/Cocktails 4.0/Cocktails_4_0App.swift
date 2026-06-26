//
//  Cocktails_4_0App.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 22/07/2025.
//

import SwiftUI
import SwiftData
import os

@main
struct Cocktails_4_0App: App {
    private let modelContainer: ModelContainer
    private let dependencies: AppDependencies
    @StateObject private var toastManager = ToastManager.shared

    init() {
        let schema = Schema([Cocktail.self, MyBar.self, PendingAction.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            self.modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            self.dependencies = AppDependencies(context: modelContainer.mainContext)
            // 3. Bootstrap immediately after container creation
            bootstrapData()
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(dependencies: dependencies)
                .environmentObject(dependencies)
                .environmentObject(toastManager)
                .toastView(toast: $toastManager.toast)
        }
        .modelContainer(modelContainer)
    }

    private func bootstrapData() {
        let context = modelContainer.mainContext
        do {
            let existingBars = try context.fetch(FetchDescriptor<MyBar>())
            guard existingBars.isEmpty else { return }

            let newBar = MyBar()
            context.insert(newBar)
            try context.save()
        } catch {
            Logger().error("Bootstrap failed: \(error)")
        }
    }
}

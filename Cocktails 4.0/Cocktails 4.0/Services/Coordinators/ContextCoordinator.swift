//
//  contextCoordinator.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 20/06/2026.
//

import Foundation
import SwiftData

@MainActor
final class ContextCoordinator {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func insert<T: PersistentModel>(_ item: T) throws {
        context.insert(item)
        try save()
    }
    
    func delete<T: PersistentModel>(_ item: T) throws {
        context.delete(item)
        try save()
    }
    
    func performBatch(_ updates: () throws -> Void) throws {
        do {
            try updates()
            try save()
        } catch {
            throw error
        }
    }
    
    func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [T] {
            return try context.fetch(descriptor)
        }
    
    func fetchOne<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> T? {
            return try fetch(descriptor).first
        }
    
    private func save() throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // If save fails, rollback
                context.rollback()
                
                throw error
            }
        }
    }
}

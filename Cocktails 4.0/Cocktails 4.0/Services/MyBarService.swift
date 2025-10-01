//
//  MyBarAPI.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 26/09/2025.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class MyBarService: ObservableObject {
    private let serviceURL = ServiceConfig.baseURL.appending(path: Endpoints.myBar)
    private let pendingActionService: PendingActionService

    init(context: ModelContext) {
        self.pendingActionService = PendingActionService(context: context)
    }
    
    // Get the users personal bar
    func fetchMyBar(context: ModelContext, userToken: String) async throws {
        let url = serviceURL
        var request = URLRequest(url: url)

        request.httpMethod = "GET"
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        
        // Await and handle response from server
        let (data, response) = try await URLSession.shared.data(for: request)
        if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
            throw error
        }
        
        let myBarDTO = try JSONDecoder().decode(MyBarDTO.self, from: data)
        let personalBar = MyBar(from: myBarDTO)

        do {
            context.insert(personalBar)
            try context.save()
        } catch {
            throw ErrorOutput.customError(message: "Error occurred when trying to save context")
        }
    }
    
    func syncAddBarItem(userToken: String) async throws {
        let url = serviceURL.appending(path: "items")
        let actions = pendingActionService.fetchActions(ofType: .addBarItem)
        
        for action in actions {
            guard let dto = action.decodePayload(as: MyBarItemDTO.self)
            else {
                print("could not decode")
                continue
            }
            
            var request = URLRequest(url: url)
            
            request.httpMethod = "POST"
            request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body = try JSONEncoder().encode(dto)
            request.httpBody = body
            
            // Await and handle response from server
            let (data, response) = try await URLSession.shared.data(for: request)
            if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
                throw error
            }
            
            pendingActionService.remove(action)
            
        }
    }
    
    func syncDeleteBarItem(userToken: String) async throws {
        let actions = pendingActionService.fetchActions(ofType: .deleteBarItem)
        
        for action in actions {
            guard let dto = action.decodePayload(as: MyBarItemDTO.self)
            else {
                continue
            }
            
            let url = serviceURL.appending(path: "items").appending(path: dto.name)
            var request = URLRequest(url: url)
            
            request.httpMethod = "DELETE"
            request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
            
            // Await and handle response from server
            let (data, response) = try await URLSession.shared.data(for: request)
            if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
                throw error
            }
            
            pendingActionService.remove(action)
        }
    }
    
    func syncAddFavorites(userToken: String) async throws {
        let actions = pendingActionService.fetchActions(ofType: .addFavorite)
        
        for action in actions {
            guard let cocktailID = action.decodePayload(as: String.self)
            else {
                continue
            }
            
            let url = serviceURL.appending(path: "favorites").appending(path: cocktailID)
            var request = URLRequest(url: url)
            
            request.httpMethod = "POST"
            request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
            
            // Await and handle response from server
            let (data, response) = try await URLSession.shared.data(for: request)
            if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
                throw error
            }
            
            pendingActionService.remove(action)
        }
    }
    
    func syncDeleteFavorites(userToken: String) async throws {
        let actions = pendingActionService.fetchActions(ofType: .deleteFavorite)
        
        for action in actions {
            guard let cocktailID = action.decodePayload(as: String.self)
            else {
                continue
            }
            
            let url = serviceURL.appending(path: "favorites").appending(path: cocktailID)
            var request = URLRequest(url: url)
            
            request.httpMethod = "DELETE"
            request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
            
            // Await and handle response from server
            let (data, response) = try await URLSession.shared.data(for: request)
            if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
                throw error
            }
            
            pendingActionService.remove(action)
        }
    }
    
    func syncAddRemoves(userToken: String) async throws {
        let url = serviceURL.appending(path: "removed")
        let actions = pendingActionService.fetchActions(ofType: .addRemoved)
        
        for action in actions {
            guard let dto = action.decodePayload(as: RemovedCocktailDTO.self)
            else {
                continue
            }
            
            var request = URLRequest(url: url)
            
            request.httpMethod = "POST"
            request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body = try JSONEncoder().encode(dto)
            request.httpBody = body
            
            // Await and handle response from server
            let (data, response) = try await URLSession.shared.data(for: request)
            if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
                throw error
            }
            
            pendingActionService.remove(action)
        }
    }
    
    func syncDeleteRemoves(userToken: String) async throws {
        let actions = pendingActionService.fetchActions(ofType: .deleteRemoved)
        
        for action in actions {
            guard let dto = action.decodePayload(as: RemovedCocktailDTO.self)
            else {
                continue
            }
            
            let url = serviceURL.appending(path: "removed").appending(path: dto.id)
            var request = URLRequest(url: url)
            
            request.httpMethod = "DELETE"
            request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
            
            // Await and handle response from server
            let (data, response) = try await URLSession.shared.data(for: request)
            if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
                throw error
            }
            
            pendingActionService.remove(action)
        }
    }
    
}

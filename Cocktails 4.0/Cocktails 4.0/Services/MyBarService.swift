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
    func fetchMyBar(context: ModelContext, userToken: String) async throws -> MyBar {
        let url = serviceURL
        
        // Request info
        var request = createRequestHeader(url: url, method: "GET", token: userToken)
        
        // Await and handle response from server
        let (data, response) = try await URLSession.shared.data(for: request)
        if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
            throw error
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let myBarDTO = try decoder.decode(MyBarDTO.self, from: data)
        let personalBar = MyBar(from: myBarDTO)

        do {
            context.insert(personalBar)
            try context.save()
        } catch {
            throw ErrorOutput.customError(message: "Error occurred when trying to save context")
        }
        
        return personalBar
    }
    
    func addBarItem(userToken: String) async throws {
        let url = serviceURL.appending(path: "items")
        let actions = try pendingActionService.fetchActions(ofType: .addBarItem)
        
        for action in actions {
            guard let dto = action.decodePayload(as: MyBarItemDTO.self)
            else {
                print("could not decode")
                continue
            }
            
            // Request info
            var request = createRequestHeader(url: url, method: "POST", token: userToken, setApplicationField: true)
            
            let body = try JSONEncoder().encode(dto)
            request.httpBody = body
            
            // Await and handle response from server
            let (data, response) = try await URLSession.shared.data(for: request)
            if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
                throw error
            }
            
            try pendingActionService.remove(action)
            
        }
    }
    
    func deleteBarItem(userToken: String) async throws {
        let actions = try pendingActionService.fetchActions(ofType: .deleteBarItem)
        
        for action in actions {
            guard let dto = action.decodePayload(as: MyBarItemDTO.self)
            else {
                continue
            }
            
            let url = serviceURL.appending(path: "items").appending(path: dto.name)
            
            // Request info
            var request = createRequestHeader(url: url, method: "DELETE", token: userToken)
            
            // Await and handle response from server
            let (data, response) = try await URLSession.shared.data(for: request)
            if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
                throw error
            }
            
            try pendingActionService.remove(action)
        }
    }
    
    func addToFavorites(userToken: String) async throws {
        let actions = try pendingActionService.fetchActions(ofType: .addFavorite)
        
        for action in actions {
            guard let cocktailID = action.decodePayload(as: String.self)
            else {
                continue
            }
            
            let url = serviceURL.appending(path: "favorites").appending(path: cocktailID)
            
            // Request info
            var request = createRequestHeader(url: url, method: "POST", token: userToken)
            
            // Await and handle response from server
            let (data, response) = try await URLSession.shared.data(for: request)
            if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
                throw error
            }
            
            try pendingActionService.remove(action)
        }
    }
    
    func deleteFromFavorites(userToken: String) async throws {
        let actions = try pendingActionService.fetchActions(ofType: .deleteFavorite)
        
        for action in actions {
            guard let cocktailID = action.decodePayload(as: String.self)
            else {
                continue
            }
            
            let url = serviceURL.appending(path: "favorites").appending(path: cocktailID)

            // Request info
            var request = createRequestHeader(url: url, method: "DELETE", token: userToken)
            
            // Await and handle response from server
            let (data, response) = try await URLSession.shared.data(for: request)
            if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
                throw error
            }
            
            try pendingActionService.remove(action)
        }
    }
    
    func addRemovedCocktail(userToken: String) async throws {
        let url = serviceURL.appending(path: "removed")
        let actions = try pendingActionService.fetchActions(ofType: .addRemoved)
        
        // JSON encoder with ISO8601 date format - Vapor expect date as string, swift uses number by default
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        for action in actions {
            guard let dto = action.decodePayload(as: RemovedCocktailDTO.self)
            else {
                continue
            }
            
            // Request info
            var request = createRequestHeader(url: url, method: "POST", token: userToken, setApplicationField: true)
            
            // Encode body
            let body = try encoder.encode(dto)
            request.httpBody = body
            
            let (data, response) = try await URLSession.shared.data(for: request)
            if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
                throw error
            }
            
            try pendingActionService.remove(action)
        }
    }
    
    func deleteRemovedCocktail(userToken: String) async throws {
        let actions = try pendingActionService.fetchActions(ofType: .deleteRemoved)
        
        for action in actions {
            guard let dto = action.decodePayload(as: RemovedCocktailDTO.self)
            else {
                continue
            }
            
            let url = serviceURL.appending(path: "removed").appending(path: dto.id)
            
            // Request info
            var request = createRequestHeader(url: url, method: "DELETE", token: userToken)
            
            // Await and handle response from server
            let (data, response) = try await URLSession.shared.data(for: request)
            if let error = ErrorHandler.mapHTTPResponse(response, data: data) {
                throw error
            }
            
            try pendingActionService.remove(action)
        }
    }
}

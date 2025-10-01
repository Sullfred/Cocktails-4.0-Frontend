//
//  ServiceConfig.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 26/09/2025.
//
import Foundation

struct ServiceConfig {
    // Get from environment
    static let baseURL: URL = {URL(string: ProcessInfo.processInfo.environment["SERVER_URL"] ?? "http://127.0.0.1:8080")!}()
}

struct Endpoints {
    static let cocktails = "cocktails"
    static let user = "users"
    static let myBar = "mybar"
}

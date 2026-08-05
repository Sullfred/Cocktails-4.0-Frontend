//
//  ServiceConfig.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 26/09/2025.
//
import Foundation

public enum ServiceConfig {
    // Get from environment
    enum Keys {
        static let apiKey = "API_KEY"
        static let apiUrl = "API_URL"
        static let host = "API_HOST"
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("pList file not found")
        }
        return dict
    }()
    
    
    static let baseURL: URL = {
        guard let host = ServiceConfig.infoDictionary[Keys.host] as? String else {
            fatalError("API host not set")
        }
        
        guard let baseurl = ServiceConfig.infoDictionary[Keys.apiUrl] as? String else {
            fatalError("API url not set")
        }
        
        guard let url = URL(string: "\(host)://\(baseurl)") else {
                fatalError("Invalid API HOST")
            }
        
        return url
    }()
    
    static let apiKey: String = {
        guard let keyString = ServiceConfig.infoDictionary[Keys.apiKey] as? String else {
            fatalError("API Key not set")
        }
        return keyString
    }()
}

struct Endpoints {
    static let cocktails = "cocktails"
    static let user = "users"
    static let myBar = "mybar"
    static let image = "image"
}

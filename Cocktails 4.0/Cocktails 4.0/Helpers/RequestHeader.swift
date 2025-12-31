//
//  RequestHeader.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 28/12/2025.
//

import Foundation

func createRequestHeader (url: URL, method: String, token: String? = nil, setApplicationField: Bool = false) -> URLRequest {
    let apiKey = ProcessInfo.processInfo.environment["COCKTAILS_API_KEY"]
    
    var request = URLRequest(url: url)
    request.httpMethod = method
    request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
    
    if setApplicationField {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    if let token {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    return request
}

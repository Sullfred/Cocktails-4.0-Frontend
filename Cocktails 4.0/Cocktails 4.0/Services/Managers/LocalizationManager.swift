//
//  LocalizationManager.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 22/07/2026.
//

import Foundation
import SwiftUI

@MainActor
final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @AppStorage("currentLanguage")
    var currentLanguage: LanguageType = .english
}


enum LanguageType: String, CaseIterable {
    case english = "en"
    case danish = "da"

    var name: String {
        switch self {
        case .english: return "English"
        case .danish: return "Dansk"
        }
    }
}

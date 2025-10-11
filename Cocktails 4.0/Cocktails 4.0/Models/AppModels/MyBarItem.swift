//
//  MyBarItem.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 12/08/2025.
//

import SwiftUI
import Foundation
import SwiftData

class MyBarItem: Codable, Identifiable, Hashable {
    var name: String
    var category: BarItemCategory
    
    init(name: String = "", category: BarItemCategory = .other) {
        self.name = name
        self.category = category
    }
    
    static func == (lhs: MyBarItem, rhs: MyBarItem) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

enum BarItemCategory: String, Codable, CaseIterable {
    case liquor, juice, bitter, mixer, sweetener, other

    var id: String { rawValue.capitalized }
}


extension MyBarItem {
    private static func loadKeywords() -> [BarItemCategory: [String]] {
        guard let url = Bundle.main.url(forResource: "BarItemKeywords", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: [String]].self, from: data) else {
            return [:]
        }
        
        var result: [BarItemCategory: [String]] = [:]
        for (key, value) in decoded {
            if let category = BarItemCategory(rawValue: key) {
                result[category] = value
            }
        }
        return result
    }
    
    private static let priorities: [BarItemCategory: Int] = [
        .liquor: 5,
        .sweetener: 3,
        .juice: 3,
        .bitter: 2,
        .mixer: 1,
        .other: 0
    ]
    
    func assignCategoryBasedOnName() {
        let normalizedName = name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        let categoryKeywords = Self.loadKeywords()
        var matchedCategories: [BarItemCategory] = []
        
        for (category, keywords) in categoryKeywords {
            for keyword in keywords {
                if normalizedName.range(of: "\\b\(NSRegularExpression.escapedPattern(for: keyword.lowercased()))\\b",
                                        options: .regularExpression) != nil {
                    matchedCategories.append(category)
                    break
                }
            }
        }
        
        if matchedCategories.isEmpty {
            self.category = .other
            return
        }
        
        let sortedCategories = matchedCategories.sorted {
            (Self.priorities[$0] ?? 0) > (Self.priorities[$1] ?? 0)
        }
        
        self.category = sortedCategories.first ?? .other
    }
}

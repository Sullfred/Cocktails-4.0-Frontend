//
//  LanguageSection.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 23/07/2026.
//

import SwiftUI

struct LanguageSection: View {
    @EnvironmentObject var localizationManager: LocalizationManager

    var body: some View {
        GroupBox {
            Picker(
                "language",
                selection: $localizationManager.currentLanguage
            ) {
                ForEach(LanguageType.allCases, id: \.self) { language in
                    Text(language.name)
                        .tag(language)
                }
            }
            .pickerStyle(.navigationLink)
        } label: {
            Label("language", systemImage: "globe")
        }
        .backgroundStyle(Color.backgroundSecondary)
    }
}

//
//  view_notes.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 19/08/2025.
//

import SwiftUI

struct GuideAndNotes: Codable {
    let title: String
    let introduction: String
    let sections: [GuideSection]
}

struct GuideSection: Codable {
    let subtitle: String
    let body: String
    let subsections: [GuideSubsection]?
}

struct GuideSubsection: Codable {
    let headline: String
    let description: String
}

struct view_notes: View {
    @State private var guide: GuideAndNotes?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let guide = guide {
                    Text(guide.title)
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 8)

                    Text(guide.introduction)
                        .font(.body)
                        .padding(.bottom, 16)

                    ForEach(guide.sections, id: \.subtitle) { section in
                        DisclosureGroup(section.subtitle) {
                            Text(section.body)
                                .font(.body)
                                .padding(.bottom, 8)

                            if let subsections = section.subsections {
                                ForEach(subsections, id: \.headline) { subsection in
                                    Text(subsection.headline)
                                        .font(.headline)

                                    Text(subsection.description)
                                        .font(.body)
                                        .padding(.bottom, 8)
                                }
                            }
                        }
                        .font(.title3)
                        .tint(.colorSet4)
                    }
                } else {
                    Text("Loading...")
                        .font(.body)
                        .padding()
                }
            }
            .padding()
        }
        .task {
            if let url = Bundle.main.url(forResource: "GuideAndNotes", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let decodedGuide = try JSONDecoder().decode(GuideAndNotes.self, from: data)
                    guide = decodedGuide
                } catch {
                    print("Failed to load or decode GuideAndNotes.json: \(error)")
                }
            } else {
                print("GuideAndNotes.json not found in bundle.")
            }
        }
        .background(Color.colorSet2)
    }
}

#Preview {
    view_notes()
}

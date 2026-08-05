//
//  MultiSelectButtonView.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 15/08/2025.
//

import SwiftUI

struct MultiSelectButtonView<T: Identifiable & Hashable, Content: View>: View {
    let options: [T]
    @Binding var selection: [T?]
    @ViewBuilder let content: (T) -> Content
    
    init(
        _ options: [T],
        _ selection: Binding<[T?]>,
        @ViewBuilder _ content: @escaping (T) -> Content
    ) {
        self.options = options
        self._selection = selection
        self.content = content
    }
    
    var body: some View {
        Group {
            VStack(alignment: .leading) {
                ForEach(options, id: \.self) { option in
                    Button {
                        if selection.contains(option) {
                            selection.removeAll { $0 == option }
                        } else {
                            selection.append(option)
                        }
                    }
                    label: {
                        content(option)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

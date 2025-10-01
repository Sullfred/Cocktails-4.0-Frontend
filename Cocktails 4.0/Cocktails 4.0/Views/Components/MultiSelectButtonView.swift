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
    
    /*
     init methods aren't required for SwiftUI to work, however in this example,
     I wanted to see only the variables at the call site (not the parameter names for the views).
     */
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
        // I have chosen to use a Group here to allow the parent component decide how this view should be displayed
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

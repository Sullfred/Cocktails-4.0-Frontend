//
//  ToastManager.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 28/08/2025.
//


import SwiftUI
import Combine

class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    @Published var toast: Toast?
    
    private init() {}
    
    func show(style: ToastStyle, message: String) {
        DispatchQueue.main.async {
            self.toast = Toast(style: style, message: message)
        }
    }
}

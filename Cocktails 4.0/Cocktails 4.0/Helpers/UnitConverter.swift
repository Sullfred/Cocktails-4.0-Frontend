//
//  Helpers.swift
//  Cocktails 4.0
//
//  Created by Daniel Vang Kleist on 22/07/2025.
//

import Foundation
import SwiftData
import SwiftUI

func convertUnit(ingredient: Ingredient, targetUnit: UnitVolume) -> Double? {
    guard let fromUnit = ingredient.unit.ingredientUnit else {
        return nil // unsupported conversion
    }
    
    let rawValue = Measurement(value: ingredient.volume, unit: fromUnit).converted(to: targetUnit).value
    
    // Define workable increments for cocktail measurements
    let increment: Double
    if targetUnit == .fluidOunces {
        increment = 0.25 // Round to nearest 1/4 oz
    } else if targetUnit == .milliliters {
        increment = 2.5    // Round to nearest 2.5ml (matches your 22.5ml example)
    } else if targetUnit == .centiliters {
        increment = 0.5    // Round to nearest 0.5cl
    } else {
        return rawValue // Return precise value for other units
    }
    
    // Round to the nearest increment
    return (rawValue / increment).rounded() * increment
}


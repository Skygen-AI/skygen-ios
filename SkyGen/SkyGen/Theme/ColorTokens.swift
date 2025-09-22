//
//  ColorTokens.swift
//  SkyGen
//
//  Complete theme structure using Assets.xcassets for adaptive themes
//

import SwiftUI

// MARK: - Theme Structure
struct Theme {
    struct Colors {
        // Background
        let background = Color("Background")
        let backgroundSecondary = Color("BackgroundSecondary")
        let backgroundTertiary = Color("BackgroundTertiary")
        
        // Surface
        let surface = Color("Surface")
        let surfaceElevated = Color("SurfaceElevated")
        let surfaceHighest = Color("SurfaceHighest")
        
        // Text
        let textPrimary = Color("TextPrimary")
        let textSecondary = Color("TextSecondary")
        let textTertiary = Color("TextTertiary")
        let textDisabled = Color("TextDisabled")
        
        // Border & Dividers
        let border = Color("Border")
        let borderSubtle = Color("BorderSubtle")
        let divider = Color("Divider")
        
        // Accent & Semantic
        let accent = Color.accentColor
        let success = Color("Success")
        let warning = Color("Warning")
        let error = Color("Error")
        
        // Interactive
        let interactive = Color.accentColor
        let interactivePressed = Color("InteractivePressed")
        let interactiveDisabled = Color("InteractiveDisabled")
        
        // Legacy support (mapping to new colors)
        let primary = Color("TextPrimary")
        let primaryVariant = Color("TextSecondary")
        let secondary = Color("TextSecondary")
        let secondaryVariant = Color("TextTertiary")
        let accentPressed = Color("InteractivePressed")
    }
    
    static let colors = Colors()
}

// MARK: - Legacy Extensions (for backward compatibility)
extension Color {
    // Keep these for any hardcoded references that might still exist
    static let skyBackground = Color("Background")
    static let skyTextPrimary = Color("TextPrimary")
    static let skySurface = Color("Surface")
}
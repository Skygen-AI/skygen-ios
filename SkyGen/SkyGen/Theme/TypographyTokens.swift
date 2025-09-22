//
//  TypographyTokens.swift
//  SkyGen
//
//  Typography tokens based on SF Pro family
//

import SwiftUI

extension Font {
    // MARK: - Display Fonts (Large headings)
    static let displayLarge = Font.system(size: 32, weight: .bold, design: .default)
    static let displayMedium = Font.system(size: 28, weight: .bold, design: .default)
    static let displaySmall = Font.system(size: 24, weight: .semibold, design: .default)
    
    // MARK: - Headline Fonts
    static let headlineLarge = Font.system(size: 22, weight: .semibold, design: .default)
    static let headlineMedium = Font.system(size: 20, weight: .semibold, design: .default)
    static let headlineSmall = Font.system(size: 18, weight: .medium, design: .default)
    
    // MARK: - Title Fonts
    static let titleLarge = Font.system(size: 16, weight: .medium, design: .default)
    static let titleMedium = Font.system(size: 14, weight: .medium, design: .default)
    static let titleSmall = Font.system(size: 12, weight: .medium, design: .default)
    
    // MARK: - Body Fonts
    static let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 12, weight: .regular, design: .default)
    
    // MARK: - Label Fonts
    static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)
    static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
    static let labelSmall = Font.system(size: 10, weight: .medium, design: .default)
    
    // MARK: - Caption Fonts
    static let caption = Font.system(size: 10, weight: .regular, design: .default)
    static let captionSmall = Font.system(size: 8, weight: .regular, design: .default)
    
    // MARK: - Monospace (for code blocks)
    static let codeLarge = Font.system(size: 14, weight: .regular, design: .monospaced)
    static let codeMedium = Font.system(size: 12, weight: .regular, design: .monospaced)
    static let codeSmall = Font.system(size: 10, weight: .regular, design: .monospaced)
}

// MARK: - Typography Theme Extension
extension Theme {
    struct Typography {
        // Display
        let displayLarge = Font.displayLarge
        let displayMedium = Font.displayMedium
        let displaySmall = Font.displaySmall
        
        // Headlines
        let headlineLarge = Font.headlineLarge
        let headlineMedium = Font.headlineMedium
        let headlineSmall = Font.headlineSmall
        
        // Titles
        let titleLarge = Font.titleLarge
        let titleMedium = Font.titleMedium
        let titleSmall = Font.titleSmall
        
        // Body
        let bodyLarge = Font.bodyLarge
        let bodyMedium = Font.bodyMedium
        let bodySmall = Font.bodySmall
        
        // Labels
        let labelLarge = Font.labelLarge
        let labelMedium = Font.labelMedium
        let labelSmall = Font.labelSmall
        
        // Caption
        let caption = Font.caption
        let captionSmall = Font.captionSmall
        
        // Code
        let codeLarge = Font.codeLarge
        let codeMedium = Font.codeMedium
        let codeSmall = Font.codeSmall
    }
    
    static let typography = Typography()
}

// MARK: - Line Height and Letter Spacing
struct TextStyle {
    let font: Font
    let lineHeight: CGFloat
    let letterSpacing: CGFloat
    
    static let displayLarge = TextStyle(font: .displayLarge, lineHeight: 40, letterSpacing: -0.5)
    static let displayMedium = TextStyle(font: .displayMedium, lineHeight: 36, letterSpacing: -0.3)
    static let displaySmall = TextStyle(font: .displaySmall, lineHeight: 32, letterSpacing: 0)
    
    static let headlineLarge = TextStyle(font: .headlineLarge, lineHeight: 28, letterSpacing: 0)
    static let headlineMedium = TextStyle(font: .headlineMedium, lineHeight: 26, letterSpacing: 0)
    static let headlineSmall = TextStyle(font: .headlineSmall, lineHeight: 24, letterSpacing: 0)
    
    static let titleLarge = TextStyle(font: .titleLarge, lineHeight: 22, letterSpacing: 0.1)
    static let titleMedium = TextStyle(font: .titleMedium, lineHeight: 20, letterSpacing: 0.1)
    static let titleSmall = TextStyle(font: .titleSmall, lineHeight: 18, letterSpacing: 0.1)
    
    static let bodyLarge = TextStyle(font: .bodyLarge, lineHeight: 24, letterSpacing: 0.15)
    static let bodyMedium = TextStyle(font: .bodyMedium, lineHeight: 20, letterSpacing: 0.25)
    static let bodySmall = TextStyle(font: .bodySmall, lineHeight: 18, letterSpacing: 0.4)
    
    static let labelLarge = TextStyle(font: .labelLarge, lineHeight: 20, letterSpacing: 0.1)
    static let labelMedium = TextStyle(font: .labelMedium, lineHeight: 16, letterSpacing: 0.5)
    static let labelSmall = TextStyle(font: .labelSmall, lineHeight: 14, letterSpacing: 0.5)
    
    static let caption = TextStyle(font: .caption, lineHeight: 14, letterSpacing: 0.4)
    static let captionSmall = TextStyle(font: .captionSmall, lineHeight: 12, letterSpacing: 0.5)
}

// MARK: - Text Style Modifier
struct TextStyleModifier: ViewModifier {
    let style: TextStyle
    
    func body(content: Content) -> some View {
        content
            .font(style.font)
            .lineSpacing(style.lineHeight - UIFont.preferredFont(forTextStyle: .body).lineHeight)
            .kerning(style.letterSpacing)
    }
}

extension View {
    func textStyle(_ style: TextStyle) -> some View {
        modifier(TextStyleModifier(style: style))
    }
}

// Static instance defined in individual extension

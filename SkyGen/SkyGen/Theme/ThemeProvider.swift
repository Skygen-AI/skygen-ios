//
//  ThemeProvider.swift
//  SkyGen
//
//  Central theme provider for the entire app
//

import SwiftUI

// MARK: - Theme Environment Key
struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue = AppTheme.dark
}

extension EnvironmentValues {
    var theme: AppTheme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

// MARK: - App Theme
struct AppTheme {
    let colors: Theme.Colors
    let typography: Theme.Typography
    let spacing: Theme.Spacing
    let radius: Theme.Radius
    let shadow: Theme.Shadow
    let motion: Theme.Motion
    
    static let dark: AppTheme = {
        return AppTheme(
            colors: Theme.colors,
            typography: Theme.typography,
            spacing: Theme.spacing,
            radius: Theme.radius,
            shadow: Theme.shadow,
            motion: Theme.motion
        )
    }()
}

// MARK: - Theme Provider View
struct ThemeProvider<Content: View>: View {
    let theme: AppTheme
    let content: Content
    
    init(theme: AppTheme = .dark, @ViewBuilder content: () -> Content) {
        self.theme = theme
        self.content = content()
    }
    
    var body: some View {
        content
            .environment(\.theme, theme)
            // Remove .preferredColorScheme to use system setting
    }
}

// MARK: - Theme Access Helper
extension View {
    func withTheme<Content: View>(@ViewBuilder content: @escaping (AppTheme) -> Content) -> some View {
        GeometryReader { _ in
            EnvironmentReader(\.theme) { theme in
                content(theme)
            }
        }
    }
}

// MARK: - Environment Reader Helper
struct EnvironmentReader<Value, Content: View>: View {
    let keyPath: KeyPath<EnvironmentValues, Value>
    let content: (Value) -> Content
    
    init(_ keyPath: KeyPath<EnvironmentValues, Value>, @ViewBuilder content: @escaping (Value) -> Content) {
        self.keyPath = keyPath
        self.content = content
    }
    
    var body: some View {
        GeometryReader { _ in
            EnvironmentReaderInternal(keyPath: keyPath, content: content)
        }
    }
}

private struct EnvironmentReaderInternal<Value, Content: View>: View {
    let keyPath: KeyPath<EnvironmentValues, Value>
    let content: (Value) -> Content
    @Environment(\.self) private var environment
    
    var body: some View {
        content(environment[keyPath: keyPath])
    }
}

// MARK: - Common Theme Modifiers
extension View {
    func primaryBackground() -> some View {
        background(Color.background)
    }
    
    func secondaryBackground() -> some View {
        background(Color.backgroundSecondary)
    }
    
    func surfaceBackground() -> some View {
        background(Color.surface)
    }
    
    func elevatedSurface() -> some View {
        background(Color.surfaceElevated)
    }
    
    func cardStyle() -> some View {
        background(Color.surface)
            .cornerRadius(Theme.radius.card)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    func primaryText() -> some View {
        foregroundColor(Color.textPrimary)
    }
    
    func secondaryText() -> some View {
        foregroundColor(Color.textSecondary)
    }
    
    func tertiaryText() -> some View {
        foregroundColor(Color.textTertiary)
    }
    
    func accentColor() -> some View {
        foregroundColor(Color.accentColor)
    }
}

// MARK: - Theme-aware Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(theme.typography.titleLarge)
            .foregroundColor(isEnabled ? .white : theme.colors.textDisabled)
            .padding(.vertical, theme.spacing.buttonPaddingVertical * 1.5)
            .padding(.horizontal, theme.spacing.buttonPaddingHorizontal)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.button)
                    .fill(isEnabled ? Color.accentColor : theme.colors.interactiveDisabled)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(theme.motion.easing.standard, value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(theme.typography.labelLarge)
            .foregroundColor(isEnabled ? Color.accentColor : theme.colors.textDisabled)
            .padding(.vertical, theme.spacing.buttonPaddingVertical)
            .padding(.horizontal, theme.spacing.buttonPaddingHorizontal)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.button)
                    .stroke(isEnabled ? Color.accentColor : theme.colors.interactiveDisabled, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(theme.motion.easing.standard, value: configuration.isPressed)
    }
}

struct TertiaryButtonStyle: ButtonStyle {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(theme.typography.labelLarge)
            .foregroundColor(isEnabled ? Color.accentColor : theme.colors.textDisabled)
            .padding(.vertical, theme.spacing.buttonPaddingVertical)
            .padding(.horizontal, theme.spacing.buttonPaddingHorizontal)
            .background(
                configuration.isPressed ? Color.accentColor.opacity(0.1) : Color.clear
            )
            .cornerRadius(theme.radius.button)
            .animation(theme.motion.easing.standard, value: configuration.isPressed)
    }
}

struct DestructiveButtonStyle: ButtonStyle {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(theme.typography.labelLarge)
            .foregroundColor(Color.white)
            .padding(.vertical, theme.spacing.buttonPaddingVertical)
            .padding(.horizontal, theme.spacing.buttonPaddingHorizontal)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.button)
                    .fill(isEnabled ? theme.colors.error : theme.colors.interactiveDisabled)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(theme.motion.easing.standard, value: configuration.isPressed)
    }
}

// MARK: - Button Style Extensions
extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}

extension ButtonStyle where Self == TertiaryButtonStyle {
    static var tertiary: TertiaryButtonStyle { TertiaryButtonStyle() }
}

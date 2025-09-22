//
//  SpacingTokens.swift
//  SkyGen
//
//  Spacing, radius, shadow and motion tokens
//

import SwiftUI

// MARK: - Spacing Scale
struct SpacingTokens {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
    
    // Component specific spacing
    static let buttonPaddingVertical: CGFloat = 12
    static let buttonPaddingHorizontal: CGFloat = 20
    static let cardPadding: CGFloat = 16
    static let screenPadding: CGFloat = 20
    static let listItemPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 24
}

// MARK: - Border Radius
struct RadiusTokens {
    static let none: CGFloat = 0
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let full: CGFloat = 9999
    
    // Component specific radius
    static let button: CGFloat = 16
    static let card: CGFloat = 12
    static let textField: CGFloat = 8
    static let modal: CGFloat = 16
    static let avatar: CGFloat = 9999
}

// MARK: - Shadows
struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    let opacity: Double
    
    static let none = ShadowStyle(color: .clear, radius: 0, x: 0, y: 0, opacity: 0)
    
    static let subtle = ShadowStyle(
        color: .black,
        radius: 4,
        x: 0,
        y: 2,
        opacity: 0.1
    )
    
    static let medium = ShadowStyle(
        color: .black,
        radius: 8,
        x: 0,
        y: 4,
        opacity: 0.15
    )
    
    static let strong = ShadowStyle(
        color: .black,
        radius: 16,
        x: 0,
        y: 8,
        opacity: 0.2
    )
    
    static let card = ShadowStyle(
        color: .black,
        radius: 6,
        x: 0,
        y: 3,
        opacity: 0.12
    )
}

// MARK: - Opacity Levels
struct Opacity {
    static let disabled: Double = 0.38
    static let inactive: Double = 0.6
    static let pressed: Double = 0.12
    static let hover: Double = 0.08
    static let focus: Double = 0.12
    static let overlay: Double = 0.5
    static let backdrop: Double = 0.8
}

// MARK: - Motion (Animation) Tokens
struct MotionTokens {
    // Duration
    struct Duration {
        static let fast: Double = 0.15
        static let medium: Double = 0.25
        static let slow: Double = 0.35
        static let slower: Double = 0.5
    }
    
    // Easing curves
    struct Easing {
        static let standard = Animation.easeInOut(duration: Duration.medium)
        static let emphasized = Animation.spring(response: 0.6, dampingFraction: 0.8)
        static let decelerated = Animation.easeOut(duration: Duration.medium)
        static let accelerated = Animation.easeIn(duration: Duration.fast)
        
        // Custom curves
        static let bounce = Animation.interpolatingSpring(
            mass: 1.0,
            stiffness: 180,
            damping: 12
        )
        
        static let gentle = Animation.easeInOut(duration: Duration.slow)
    }
    
    // Preset animations for common use cases
    struct Preset {
        static let fadeIn = AnyTransition.opacity.animation(.easeIn(duration: Duration.fast))
        static let fadeOut = AnyTransition.opacity.animation(.easeOut(duration: Duration.fast))
        static let slideUp = AnyTransition.move(edge: .bottom).animation(Easing.emphasized)
        static let slideDown = AnyTransition.move(edge: .top).animation(Easing.emphasized)
        static let scale = AnyTransition.scale.animation(Easing.bounce)
    }
}

// MARK: - Theme Extension
extension Theme {
    struct Spacing {
        let xs = SpacingTokens.xs
        let sm = SpacingTokens.sm
        let md = SpacingTokens.md
        let lg = SpacingTokens.lg
        let xl = SpacingTokens.xl
        let xxl = SpacingTokens.xxl
        let xxxl = SpacingTokens.xxxl
        
        let buttonPaddingVertical = SpacingTokens.buttonPaddingVertical
        let buttonPaddingHorizontal = SpacingTokens.buttonPaddingHorizontal
        let cardPadding = SpacingTokens.cardPadding
        let screenPadding = SpacingTokens.screenPadding
        let listItemPadding = SpacingTokens.listItemPadding
        let sectionSpacing = SpacingTokens.sectionSpacing
    }
    
    struct Radius {
        let none = RadiusTokens.none
        let xs = RadiusTokens.xs
        let sm = RadiusTokens.sm
        let md = RadiusTokens.md
        let lg = RadiusTokens.lg
        let xl = RadiusTokens.xl
        let full = RadiusTokens.full
        
        let button = RadiusTokens.button
        let card = RadiusTokens.card
        let textField = RadiusTokens.textField
        let modal = RadiusTokens.modal
        let avatar = RadiusTokens.avatar
        let sheet = RadiusTokens.modal
    }
    
    struct Shadow {
        let none = ShadowStyle.none
        let subtle = ShadowStyle.subtle
        let medium = ShadowStyle.medium
        let strong = ShadowStyle.strong
        let card = ShadowStyle.card
    }
    
    struct Motion {
        let duration = MotionTokens.Duration.self
        let easing = MotionTokens.Easing.self
        let preset = MotionTokens.Preset.self
    }
    
    static let spacing = Spacing()
    static let radius = Radius()
    static let shadow = Shadow()
    static let motion = Motion()
}

// MARK: - View Modifiers for Shadows
struct ShadowModifier: ViewModifier {
    let style: ShadowStyle
    
    func body(content: Content) -> some View {
        content.shadow(
            color: style.color.opacity(style.opacity),
            radius: style.radius,
            x: style.x,
            y: style.y
        )
    }
}

extension View {
    func shadow(_ style: ShadowStyle) -> some View {
        modifier(ShadowModifier(style: style))
    }
}

// Static instances are defined in each individual extension

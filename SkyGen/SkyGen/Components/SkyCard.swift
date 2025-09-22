//
//  SkyCard.swift
//  SkyGen
//
//  Card component with theme support
//

import SwiftUI

struct SkyCard<Content: View>: View {
    @Environment(\.theme) private var theme
    
    let content: Content
    var padding: CGFloat? = nil
    var cornerRadius: CGFloat? = nil
    var shadowStyle: ShadowStyle? = nil
    var backgroundColor: Color? = nil
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    init(
        padding: CGFloat? = nil,
        cornerRadius: CGFloat? = nil,
        shadowStyle: ShadowStyle? = nil,
        backgroundColor: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadowStyle = shadowStyle
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        content
            .padding(padding ?? theme.spacing.cardPadding)
            .background(backgroundColor ?? theme.colors.surface)
            .cornerRadius(cornerRadius ?? theme.radius.card)
            .shadow(shadowStyle ?? theme.shadow.card)
    }
}

// MARK: - Interactive Card
struct SkyInteractiveCard<Content: View>: View {
    @Environment(\.theme) private var theme
    
    let content: Content
    let action: () -> Void
    var padding: CGFloat? = nil
    var cornerRadius: CGFloat? = nil
    var shadowStyle: ShadowStyle? = nil
    var backgroundColor: Color? = nil
    
    @State private var isPressed = false
    
    init(
        action: @escaping () -> Void,
        padding: CGFloat? = nil,
        cornerRadius: CGFloat? = nil,
        shadowStyle: ShadowStyle? = nil,
        backgroundColor: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.action = action
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadowStyle = shadowStyle
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        Button(action: {
            HapticFeedback.light()
            action()
        }) {
            content
                .padding(padding ?? theme.spacing.cardPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(PlainButtonStyle())
        .background(backgroundColor ?? theme.colors.surface)
        .cornerRadius(cornerRadius ?? theme.radius.card)
        .shadow(shadowStyle ?? theme.shadow.card)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .opacity(isPressed ? 0.9 : 1.0)
        .animation(theme.motion.easing.standard, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) {
            // Do nothing on perform
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
}

// MARK: - List Item Card
struct SkyListItem<Content: View>: View {
    @Environment(\.theme) private var theme
    
    let content: Content
    var action: (() -> Void)? = nil
    var showDisclosure: Bool = true
    
    init(
        action: (() -> Void)? = nil,
        showDisclosure: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.action = action
        self.showDisclosure = showDisclosure
    }
    
    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    itemContent
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                itemContent
            }
        }
    }
    
    private var itemContent: some View {
        HStack(spacing: theme.spacing.md) {
            content
            
            if showDisclosure && action != nil {
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.colors.textTertiary)
            }
        }
        .padding(.horizontal, theme.spacing.listItemPadding)
        .padding(.vertical, theme.spacing.sm)
        .background(theme.colors.surface)
        .contentShape(Rectangle())
    }
}

// MARK: - Status Card
struct SkyStatusCard: View {
    @Environment(\.theme) private var theme
    
    enum Status {
        case success
        case warning
        case error
        case info
        case neutral
        
        var color: Color {
            switch self {
            case .success: return Color.success
            case .warning: return Color.warning
            case .error: return Color.error
            case .info: return Color.accentColor
            case .neutral: return Color.textSecondary
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .success: return Color.success.opacity(0.1)
            case .warning: return Color.warning.opacity(0.1)
            case .error: return Color.error.opacity(0.1)
            case .info: return Color.accentColor.opacity(0.1)
            case .neutral: return Color.textSecondary.opacity(0.1)
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle"
            case .warning: return "exclamationmark.triangle"
            case .error: return "xmark.circle"
            case .info: return "info.circle"
            case .neutral: return "circle"
            }
        }
    }
    
    let status: Status
    let title: String
    let message: String
    var action: (() -> Void)? = nil
    var actionTitle: String? = nil
    
    var body: some View {
        SkyCard(backgroundColor: status.backgroundColor) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(spacing: theme.spacing.sm) {
                    Image(systemName: status.icon)
                        .foregroundColor(status.color)
                    
                    Text(title)
                        .textStyle(.titleMedium)
                        .foregroundColor(theme.colors.textPrimary)
                    
                    Spacer()
                }
                
                Text(message)
                    .textStyle(.bodySmall)
                    .foregroundColor(theme.colors.textSecondary)
                
                if let action = action, let actionTitle = actionTitle {
                    Button(actionTitle, action: action)
                        .buttonStyle(.tertiary)
                        .font(theme.typography.labelSmall)
                }
            }
        }
    }
}

// MARK: - Info Card with Icon
struct SkyInfoCard: View {
    @Environment(\.theme) private var theme
    
    let icon: String
    let title: String
    let subtitle: String?
    let value: String?
    var iconColor: Color? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        SkyCard {
            HStack(spacing: theme.spacing.md) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor ?? Color.accentColor)
                    .frame(width: 40, height: 40)
                    .background((iconColor ?? Color.accentColor).opacity(0.1))
                    .cornerRadius(theme.radius.sm)
                
                // Content
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(title)
                        .textStyle(.titleMedium)
                        .foregroundColor(theme.colors.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .textStyle(.bodySmall)
                            .foregroundColor(theme.colors.textSecondary)
                    }
                }
                
                Spacer()
                
                // Value or Action
                if let value = value {
                    Text(value)
                        .textStyle(.titleMedium)
                        .foregroundColor(theme.colors.textPrimary)
                } else if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(theme.colors.textTertiary)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                action?()
            }
        }
    }
}

#Preview("Cards") {
    ThemeProvider {
        ScrollView {
            VStack(spacing: 16) {
                SkyCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Basic Card")
                            .textStyle(.titleLarge)
                            .foregroundColor(Color.textPrimary)
                        
                        Text("This is a basic card with some content inside.")
                            .textStyle(.bodyMedium)
                            .foregroundColor(Color.textSecondary)
                    }
                }
                
                SkyInteractiveCard(action: {}) {
                    Text("Interactive Card")
                        .textStyle(.titleMedium)
                        .foregroundColor(Color.textPrimary)
                }
                
                SkyStatusCard(
                    status: .success,
                    title: "Success",
                    message: "Operation completed successfully",
                    action: {},
                    actionTitle: "Continue"
                )
                
                SkyStatusCard(
                    status: .error,
                    title: "Error",
                    message: "Something went wrong. Please try again."
                )
                
                SkyInfoCard(
                    icon: "wifi",
                    title: "WiFi Connection",
                    subtitle: "Connected to Home Network",
                    value: "5G"
                )
                
                SkyInfoCard(
                    icon: "gear",
                    title: "Settings",
                    subtitle: "Configure your preferences",
                    value: nil,
                    action: {}
                )
            }
            .padding()
        }
        .background(Color.background)
    }
}

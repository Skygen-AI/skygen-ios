import SwiftUI

// MARK: - Alert Component
struct SkyAlert: View {
    @Environment(\.theme) private var theme
    let title: String
    let message: String?
    let primaryButton: AlertButton
    let secondaryButton: AlertButton?
    
    struct AlertButton {
        let title: String
        let style: Style
        let action: () -> Void
        
        enum Style {
            case primary, secondary, destructive, cancel
        }
    }
    
    var body: some View {
        VStack(spacing: theme.spacing.lg) {
            VStack(spacing: theme.spacing.sm) {
                Text(title)
                    .textStyle(.titleMedium)
                    .foregroundColor(theme.colors.textPrimary)
                    .multilineTextAlignment(.center)
                
                if let message = message {
                    Text(message)
                        .textStyle(.bodyMedium)
                        .foregroundColor(theme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            VStack(spacing: theme.spacing.sm) {
                Button(primaryButton.title) {
                    primaryButton.action()
                }
                .buttonStyle(PrimaryButtonStyle())
                
                if let secondaryButton = secondaryButton {
                    Button(secondaryButton.title) {
                        secondaryButton.action()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
        }
        .padding(theme.spacing.lg)
        .background(theme.colors.surface)
        .cornerRadius(theme.radius.lg)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
        .frame(maxWidth: 300)
    }
    
}

// MARK: - Bottom Sheet Component
struct SkyBottomSheet<Content: View>: View {
    @Environment(\.theme) private var theme
    @Binding var isPresented: Bool
    let content: Content
    
    @State private var dragOffset: CGFloat = 0
    private let dismissThreshold: CGFloat = 100
    
    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            if isPresented {
                // Background overlay
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isPresented = false
                        }
                    }
                    .transition(.opacity)
                
                // Bottom sheet
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // Handle
                        RoundedRectangle(cornerRadius: 2)
                            .fill(theme.colors.textTertiary)
                            .frame(width: 36, height: 4)
                            .padding(.top, theme.spacing.sm)
                            .padding(.bottom, theme.spacing.md)
                        
                        // Content
                        content
                            .padding(.horizontal, theme.spacing.screenPadding)
                            .padding(.bottom, theme.spacing.screenPadding)
                    }
                    .background(theme.colors.surface)
                    .cornerRadius(theme.radius.xl, corners: [.topLeft, .topRight])
                    .offset(y: dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if value.translation.height > 0 {
                                    dragOffset = value.translation.height
                                }
                            }
                            .onEnded { value in
                                if value.translation.height > dismissThreshold {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        isPresented = false
                                    }
                                } else {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        dragOffset = 0
                                    }
                                }
                            }
                    )
                }
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPresented)
        .onChange(of: isPresented) { presented in
            if !presented {
                dragOffset = 0
            }
        }
    }
}

// MARK: - Action Sheet Component
struct SkyActionSheet: View {
    @Environment(\.theme) private var theme
    @Binding var isPresented: Bool
    let title: String?
    let message: String?
    let actions: [ActionSheetAction]
    
    struct ActionSheetAction {
        let title: String
        let style: Style
        let action: () -> Void
        
        enum Style {
            case `default`, destructive, cancel
        }
    }
    
    var body: some View {
        SkyBottomSheet(isPresented: $isPresented) {
            VStack(spacing: theme.spacing.md) {
                if title != nil || message != nil {
                    VStack(spacing: theme.spacing.xs) {
                        if let title = title {
                            Text(title)
                                .textStyle(.titleMedium)
                                .foregroundColor(theme.colors.textPrimary)
                                .multilineTextAlignment(.center)
                        }
                        
                        if let message = message {
                            Text(message)
                                .textStyle(.bodyMedium)
                                .foregroundColor(theme.colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.bottom, theme.spacing.sm)
                }
                
                VStack(spacing: theme.spacing.xs) {
                    ForEach(actions.indices, id: \.self) { index in
                        let action = actions[index]
                        
                        Button(action.title) {
                            action.action()
                            isPresented = false
                        }
                        .buttonStyle(ActionSheetButtonStyle(style: action.style))
                        
                        if index < actions.count - 1 && action.style != .cancel {
                            Divider()
                                .background(theme.colors.border)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Toast Component
struct SkyToast: View {
    @Environment(\.theme) private var theme
    let message: String
    let style: ToastStyle
    let duration: TimeInterval
    @Binding var isPresented: Bool
    
    enum ToastStyle {
        case info, success, warning, error
        
        var icon: String {
            switch self {
            case .info: return "info.circle.fill"
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            }
        }
        
        func color(from theme: AppTheme) -> Color {
            switch self {
            case .info: return Color.accentColor
            case .success: return theme.colors.success
            case .warning: return theme.colors.warning
            case .error: return theme.colors.error
            }
        }
    }
    
    init(message: String, style: ToastStyle = .info, duration: TimeInterval = 3.0, isPresented: Binding<Bool>) {
        self.message = message
        self.style = style
        self.duration = duration
        self._isPresented = isPresented
    }
    
    var body: some View {
        if isPresented {
            HStack(spacing: theme.spacing.sm) {
                Image(systemName: style.icon)
                    .foregroundColor(style.color(from: theme))
                    .font(.system(size: 20))
                
                Text(message)
                    .textStyle(.bodyMedium)
                    .foregroundColor(theme.colors.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(theme.colors.textSecondary)
                        .font(.system(size: 12, weight: .medium))
                }
            }
            .padding(theme.spacing.md)
            .background(theme.colors.surface)
            .cornerRadius(theme.radius.md)
            .shadow(theme.shadow.medium)
            .padding(.horizontal, theme.spacing.screenPadding)
            .transition(.move(edge: .top).combined(with: .opacity))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Banner Component
struct SkyBanner: View {
    @Environment(\.theme) private var theme
    let title: String
    let message: String
    let style: BannerStyle
    let action: BannerAction?
    @Binding var isPresented: Bool
    
    struct BannerAction {
        let title: String
        let action: () -> Void
    }
    
    enum BannerStyle {
        case info, success, warning, error
        
        func backgroundColor(from theme: AppTheme) -> Color {
            switch self {
            case .info: return Color.accentColor.opacity(0.1)
            case .success: return theme.colors.success.opacity(0.1)
            case .warning: return theme.colors.warning.opacity(0.1)
            case .error: return theme.colors.error.opacity(0.1)
            }
        }
        
        func borderColor(from theme: AppTheme) -> Color {
            switch self {
            case .info: return Color.accentColor
            case .success: return theme.colors.success
            case .warning: return theme.colors.warning
            case .error: return theme.colors.error
            }
        }
    }
    
    var body: some View {
        if isPresented {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text(title)
                            .textStyle(.labelLarge)
                            .foregroundColor(theme.colors.textPrimary)
                        
                        Text(message)
                            .textStyle(.bodyMedium)
                            .foregroundColor(theme.colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isPresented = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(theme.colors.textSecondary)
                            .font(.system(size: 14, weight: .medium))
                    }
                }
                
                if let action = action {
                    Button(action.title) {
                        action.action()
                    }
                    .buttonStyle(TertiaryButtonStyle())
                }
            }
            .padding(theme.spacing.md)
            .background(style.backgroundColor(from: theme))
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.md)
                    .stroke(style.borderColor(from: theme), lineWidth: 1)
            )
            .cornerRadius(theme.radius.md)
            .padding(.horizontal, theme.spacing.screenPadding)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - Custom Button Styles for Action Sheet
struct ActionSheetButtonStyle: ButtonStyle {
    @Environment(\.theme) private var theme
    let style: SkyActionSheet.ActionSheetAction.Style
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .textStyle(.bodyMedium)
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, theme.spacing.md)
            .background(configuration.isPressed ? theme.colors.surfaceElevated : Color.clear)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
    
    private var textColor: Color {
        switch style {
        case .default: return theme.colors.textPrimary
        case .destructive: return theme.colors.error
        case .cancel: return Color.accentColor
        }
    }
    
}

// MARK: - Toast Overlay Modifier
struct ToastOverlay: ViewModifier {
    @Binding var toast: SkyToast?
    
    func body(content: Content) -> some View {
        content
            .overlay(
                VStack {
                    if let toast = toast {
                        toast
                        Spacer()
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: toast != nil)
            )
    }
}

extension View {
    func toastOverlay(toast: Binding<SkyToast?>) -> some View {
        modifier(ToastOverlay(toast: toast))
    }
}

// MARK: - Preview
#Preview {
    ThemeProvider {
        VStack(spacing: 20) {
            SkyAlert(
                title: "Удалить чат?",
                message: "Это действие нельзя отменить. Все сообщения будут удалены навсегда.",
                primaryButton: SkyAlert.AlertButton(title: "Удалить", style: .destructive) { },
                secondaryButton: SkyAlert.AlertButton(title: "Отмена", style: .cancel) { }
            )
            
            SkyToast(
                message: "Сообщение отправлено успешно",
                style: .success,
                isPresented: .constant(true)
            )
            
            SkyBanner(
                title: "Новое обновление",
                message: "Доступна новая версия приложения с улучшениями безопасности",
                style: .info,
                action: SkyBanner.BannerAction(title: "Обновить") { },
                isPresented: .constant(true)
            )
        }
        .padding()
        .background(Color(red: 32/255, green: 32/255, blue: 32/255))
    }
}

//
//  SkyEmptyState.swift
//  SkyGen
//
//  Empty state component with theme support
//

import SwiftUI

struct SkyEmptyState: View {
    @Environment(\.theme) private var theme
    
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    var iconColor: Color? = nil
    
    var body: some View {
        VStack(spacing: theme.spacing.lg) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 64, weight: .light))
                .foregroundColor(iconColor ?? theme.colors.textTertiary)
            
            // Content
            VStack(spacing: theme.spacing.sm) {
                Text(title)
                    .textStyle(.headlineMedium)
                    .foregroundColor(theme.colors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .textStyle(.bodyMedium)
                    .foregroundColor(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Action Button
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .buttonStyle(.primary)
            }
        }
        .padding(theme.spacing.screenPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Loading State
struct SkyLoadingState: View {
    @Environment(\.theme) private var theme
    
    let message: String?
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: theme.spacing.lg) {
            // Loading indicator
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.accentColor))
                .scaleEffect(1.2)
            
            if let message = message {
                Text(message)
                    .textStyle(.bodyMedium)
                    .foregroundColor(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.colors.background)
    }
}

// MARK: - Error State
struct SkyErrorState: View {
    @Environment(\.theme) private var theme
    
    let title: String
    let message: String
    var retryAction: (() -> Void)? = nil
    
    var body: some View {
        SkyEmptyState(
            icon: "exclamationmark.triangle",
            title: title,
            message: message,
            actionTitle: retryAction != nil ? "Повторить" : nil,
            action: retryAction,
            iconColor: theme.colors.warning
        )
    }
}

// MARK: - Network Error State
struct SkyNetworkErrorState: View {
    let retryAction: (() -> Void)?
    
    var body: some View {
        SkyErrorState(
            title: "Нет подключения к интернету",
            message: "Проверьте подключение к сети и попробуйте снова",
            retryAction: retryAction
        )
    }
}

// MARK: - Search Empty State
struct SkySearchEmptyState: View {
    @Environment(\.theme) private var theme
    let searchQuery: String
    
    var body: some View {
        SkyEmptyState(
            icon: "magnifyingglass",
            title: "Ничего не найдено",
            message: "По запросу \"\(searchQuery)\" ничего не найдено. Попробуйте изменить поисковый запрос."
        )
    }
}

// MARK: - Content State Manager
enum ContentState {
    case loading(String? = nil)
    case empty(icon: String, title: String, message: String, actionTitle: String? = nil, action: (() -> Void)? = nil)
    case error(title: String, message: String, retryAction: (() -> Void)? = nil)
    case networkError(retryAction: (() -> Void)? = nil)
    case searchEmpty(query: String)
    case content
}

struct SkyContentStateView<Content: View>: View {
    let state: ContentState
    let content: Content
    
    init(state: ContentState, @ViewBuilder content: () -> Content) {
        self.state = state
        self.content = content()
    }
    
    var body: some View {
        switch state {
        case .loading(let message):
            SkyLoadingState(message: message)
            
        case .empty(let icon, let title, let message, let actionTitle, let action):
            SkyEmptyState(
                icon: icon,
                title: title,
                message: message,
                actionTitle: actionTitle,
                action: action
            )
            
        case .error(let title, let message, let retryAction):
            SkyErrorState(
                title: title,
                message: message,
                retryAction: retryAction
            )
            
        case .networkError(let retryAction):
            SkyNetworkErrorState(retryAction: retryAction)
            
        case .searchEmpty(let query):
            SkySearchEmptyState(searchQuery: query)
            
        case .content:
            content
        }
    }
}

#Preview("Empty States") {
    ThemeProvider {
        TabView {
            SkyEmptyState(
                icon: "message.circle",
                title: "Нет чатов",
                message: "Начните новый разговор с SkyGen AI ассистентом",
                actionTitle: "Создать чат",
                action: {}
            )
            .tabItem { Text("Empty") }
            
            SkyLoadingState(message: "Загрузка чатов...")
                .tabItem { Text("Loading") }
            
            SkyErrorState(
                title: "Ошибка сервера",
                message: "Не удалось загрузить данные. Попробуйте позже.",
                retryAction: {}
            )
            .tabItem { Text("Error") }
            
            SkyNetworkErrorState(retryAction: {})
                .tabItem { Text("Network") }
            
            SkySearchEmptyState(searchQuery: "test query")
                .tabItem { Text("Search") }
        }
    }
}

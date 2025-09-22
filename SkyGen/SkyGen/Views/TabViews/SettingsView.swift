//
//  SettingsView.swift
//  SkyGen
//
//  Settings tab view
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.theme) private var theme
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @EnvironmentObject private var navigationRouter: NavigationRouter
    
    var body: some View {
        NavigationStack(path: $navigationRouter.settingsNavigationPath) {
            List {
                // Profile Section
                Section {
                    SettingsRow(
                        icon: "person.circle",
                        title: "Профиль",
                        subtitle: "Управление аккаунтом и персональными данными"
                    ) {
                        navigationRouter.settingsNavigationPath.append(SettingsDestination.profile)
                    }
                    
                    SettingsRow(
                        icon: "bell",
                        title: "Уведомления",
                        subtitle: "Настройки push-уведомлений"
                    ) {
                        navigationRouter.settingsNavigationPath.append(SettingsDestination.notifications)
                    }
                } header: {
                    Text("Аккаунт")
                        .textStyle(.labelMedium)
                        .foregroundColor(theme.colors.textSecondary)
                        .textCase(.uppercase)
                }
                
                // Privacy & Security Section
                Section {
                    SettingsRow(
                        icon: "lock.shield",
                        title: "Безопасность",
                        subtitle: "Face ID, App Lock и двухфакторная аутентификация"
                    ) {
                        navigationRouter.settingsNavigationPath.append(SettingsDestination.security)
                    }
                    
                    SettingsRow(
                        icon: "eye.slash",
                        title: "Приватность",
                        subtitle: "Телеметрия и управление данными"
                    ) {
                        navigationRouter.settingsNavigationPath.append(SettingsDestination.privacy)
                    }
                } header: {
                    Text("Приватность и безопасность")
                        .textStyle(.labelMedium)
                        .foregroundColor(theme.colors.textSecondary)
                        .textCase(.uppercase)
                }
                
                // Help & Legal Section
                Section {
                    SettingsRow(
                        icon: "questionmark.circle",
                        title: "Помощь",
                        subtitle: "FAQ и поддержка"
                    ) {
                        navigationRouter.settingsNavigationPath.append(SettingsDestination.help)
                    }
                    
                    SettingsRow(
                        icon: "doc.text",
                        title: "Правовая информация",
                        subtitle: "Политика конфиденциальности, условия использования"
                    ) {
                        navigationRouter.settingsNavigationPath.append(SettingsDestination.legal)
                    }
                    
                    SettingsRow(
                        icon: "info.circle",
                        title: "О приложении",
                        subtitle: "Версия и информация о SkyGen"
                    ) {
                        navigationRouter.settingsNavigationPath.append(SettingsDestination.about)
                    }
                } header: {
                    Text("Поддержка")
                        .textStyle(.labelMedium)
                        .foregroundColor(theme.colors.textSecondary)
                        .textCase(.uppercase)
                }
                
                // Developer Section (for testing)
                Section {
                    SettingsRow(
                        icon: "hammer.circle",
                        title: "Сбросить онбординг",
                        subtitle: "Показать онбординг заново (для разработки)"
                    ) {
                        onboardingManager.resetOnboarding()
                    }
                } header: {
                    Text("Разработка")
                        .textStyle(.labelMedium)
                        .foregroundColor(theme.colors.textSecondary)
                        .textCase(.uppercase)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(theme.colors.background)
            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: SettingsDestination.self) { destination in
                switch destination {
                case .profile:
                    ProfileSettingsView()
                case .notifications:
                    NotificationSettingsView()
                case .security:
                    SecuritySettingsView()
                case .privacy:
                    SecuritySettingsView() // Reuse security for now
                case .help:
                    AboutView() // Reuse about for now
                case .about:
                    AboutView()
                case .legal:
                    AboutView() // Reuse about for now
                }
            }
        }
    }
}

struct SettingsRow: View {
    @Environment(\.theme) private var theme
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: theme.spacing.md) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color.accentColor)
                    .frame(width: 32, height: 32)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(theme.radius.xs)
                
                // Content
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(title)
                        .textStyle(.titleMedium)
                        .foregroundColor(theme.colors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(subtitle)
                        .textStyle(.bodySmall)
                        .foregroundColor(theme.colors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(theme.colors.textTertiary)
            }
            .padding(.vertical, theme.spacing.xs)
        }
        .buttonStyle(PlainButtonStyle())
        .listRowBackground(theme.colors.surface)
    }
}

#Preview {
    ThemeProvider {
        SettingsView()
    }
}

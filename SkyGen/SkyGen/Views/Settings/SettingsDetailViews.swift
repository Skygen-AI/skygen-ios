//
//  SettingsDetailViews.swift
//  SkyGen
//
//  Detailed settings screens
//

import SwiftUI

// MARK: - Profile Settings
struct ProfileSettingsView: View {
    @Environment(\.theme) private var theme
    @State private var displayName = "Егор Андреевич"
    @State private var email = "egor@example.com"
    @State private var avatar = "person.circle.fill"
    @State private var timeZone = "GMT+3"
    @State private var language = "Русский"
    
    var body: some View {
        List {
            // Profile Photo Section
            Section {
                HStack {
                    Spacer()
                    
                    VStack(spacing: theme.spacing.md) {
                        Button {
                            // TODO: Change avatar
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.accentColor.opacity(0.1))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: avatar)
                                    .font(.system(size: 40))
                                    .foregroundColor(Color.accentColor)
                            }
                            .overlay(
                                Circle()
                                    .stroke(theme.colors.border, lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button("Изменить фото") {
                            // TODO: Change photo
                        }
                        .font(theme.typography.labelMedium)
                        .foregroundColor(Color.accentColor)
                    }
                    
                    Spacer()
                }
            }
            
            // Personal Info Section
            Section {
                SettingsTextField(
                    title: "Имя",
                    text: $displayName,
                    placeholder: "Введите ваше имя"
                )
                
                SettingsTextField(
                    title: "Email",
                    text: $email,
                    placeholder: "email@example.com"
                )
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                
                SettingsPicker(
                    title: "Язык",
                    selection: $language,
                    options: ["Русский", "English", "Español", "Français"]
                )
                
                SettingsPicker(
                    title: "Часовой пояс",
                    selection: $timeZone,
                    options: ["GMT+3", "GMT+2", "GMT+1", "GMT", "GMT-5", "GMT-8"]
                )
            } header: {
                Text("Личная информация")
                    .textStyle(.labelMedium)
                    .foregroundColor(theme.colors.textSecondary)
                    .textCase(.uppercase)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(theme.colors.background)
        .navigationTitle("Профиль")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Сохранить") {
                    saveProfile()
                }
                .foregroundColor(Color.accentColor)
            }
        }
    }
    
    private func saveProfile() {
        // TODO: Save profile
    }
}

// MARK: - Notification Settings
struct NotificationSettingsView: View {
    @Environment(\.theme) private var theme
    @State private var pushEnabled = true
    @State private var deviceAlerts = true
    @State private var actionComplete = true
    @State private var integrationIssues = true
    @State private var dailySummary = false
    @State private var quietHoursEnabled = true
    @State private var quietStart = Date()
    @State private var quietEnd = Date()
    
    var body: some View {
        List {
            // Push Notifications Section
            Section {
                SettingsToggle(
                    title: "Push-уведомления",
                    isOn: $pushEnabled,
                    subtitle: "Основные уведомления приложения"
                )
            } header: {
                Text("Общие настройки")
                    .textStyle(.labelMedium)
                    .foregroundColor(theme.colors.textSecondary)
                    .textCase(.uppercase)
            }
            
            // Notification Types Section
            Section {
                SettingsToggle(
                    title: "Предупреждения устройств",
                    isOn: $deviceAlerts,
                    subtitle: "Уведомления о проблемах с устройствами"
                )
                
                SettingsToggle(
                    title: "Завершение действий",
                    isOn: $actionComplete,
                    subtitle: "Уведомления о завершении команд"
                )
                
                SettingsToggle(
                    title: "Проблемы интеграций",
                    isOn: $integrationIssues,
                    subtitle: "Уведомления об ошибках подключения"
                )
                
                SettingsToggle(
                    title: "Ежедневная сводка",
                    isOn: $dailySummary,
                    subtitle: "Сводка активности за день"
                )
            } header: {
                Text("Типы уведомлений")
                    .textStyle(.labelMedium)
                    .foregroundColor(theme.colors.textSecondary)
                    .textCase(.uppercase)
            }
            
            // Quiet Hours Section
            Section {
                SettingsToggle(
                    title: "Тихие часы",
                    isOn: $quietHoursEnabled,
                    subtitle: "Отключать уведомления в определенное время"
                )
                
                if quietHoursEnabled {
                    SettingsTimePicker(
                        title: "Начало",
                        time: $quietStart
                    )
                    
                    SettingsTimePicker(
                        title: "Окончание",
                        time: $quietEnd
                    )
                }
            } header: {
                Text("Расписание")
                    .textStyle(.labelMedium)
                    .foregroundColor(theme.colors.textSecondary)
                    .textCase(.uppercase)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(theme.colors.background)
        .navigationTitle("Уведомления")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Security Settings
struct SecuritySettingsView: View {
    @Environment(\.theme) private var theme
    @State private var biometricEnabled = true
    @State private var autoLockEnabled = true
    @State private var autoLockTime = "5 минут"
    @State private var twoFactorEnabled = false
    @State private var sessionTimeout = "1 час"
    
    var body: some View {
        List {
            // Authentication Section
            Section {
                SettingsToggle(
                    title: "Face ID / Touch ID",
                    isOn: $biometricEnabled,
                    subtitle: "Биометрическая аутентификация"
                )
                
                SettingsToggle(
                    title: "Автоблокировка",
                    isOn: $autoLockEnabled,
                    subtitle: "Автоматическая блокировка приложения"
                )
                
                if autoLockEnabled {
                    SettingsPicker(
                        title: "Время блокировки",
                        selection: $autoLockTime,
                        options: ["1 минута", "5 минут", "15 минут", "30 минут", "1 час"]
                    )
                }
            } header: {
                Text("Аутентификация")
                    .textStyle(.labelMedium)
                    .foregroundColor(theme.colors.textSecondary)
                    .textCase(.uppercase)
            }
            
            // Advanced Security Section
            Section {
                SettingsToggle(
                    title: "Двухфакторная аутентификация",
                    isOn: $twoFactorEnabled,
                    subtitle: "Дополнительная защита аккаунта"
                )
                
                SettingsPicker(
                    title: "Тайм-аут сессии",
                    selection: $sessionTimeout,
                    options: ["15 минут", "30 минут", "1 час", "2 часа", "8 часов"]
                )
                
                Button {
                    // TODO: Change password
                } label: {
                    HStack {
                        Text("Сменить пароль")
                            .textStyle(.bodyMedium)
                            .foregroundColor(theme.colors.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(theme.colors.textTertiary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            } header: {
                Text("Дополнительная безопасность")
                    .textStyle(.labelMedium)
                    .foregroundColor(theme.colors.textSecondary)
                    .textCase(.uppercase)
            }
            
            // Privacy Section
            Section {
                Button {
                    // TODO: Export data
                } label: {
                    HStack {
                        Text("Экспорт данных")
                            .textStyle(.bodyMedium)
                            .foregroundColor(theme.colors.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16))
                            .foregroundColor(Color.accentColor)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Button {
                    // TODO: Delete account
                } label: {
                    HStack {
                        Text("Удалить аккаунт")
                            .textStyle(.bodyMedium)
                            .foregroundColor(theme.colors.error)
                        
                        Spacer()
                        
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(theme.colors.error)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            } header: {
                Text("Конфиденциальность")
                    .textStyle(.labelMedium)
                    .foregroundColor(theme.colors.textSecondary)
                    .textCase(.uppercase)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(theme.colors.background)
        .navigationTitle("Безопасность")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - About View
struct AboutView: View {
    @Environment(\.theme) private var theme
    
    private let appVersion = "1.0.0"
    private let buildNumber = "1"
    private let teamInfo = [
        ("Разработчик", "SkyGen Team"),
        ("Дизайн", "SkyGen Design"),
        ("Поддержка", "support@skygen.app"),
        ("Сайт", "www.skygen.app")
    ]
    
    var body: some View {
        List {
            // App Info Section
            Section {
                HStack {
                    Spacer()
                    
                    VStack(spacing: theme.spacing.md) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 60))
                            .foregroundColor(Color.accentColor)
                        
                        VStack(spacing: theme.spacing.xs) {
                            Text("SkyGen")
                                .textStyle(.headlineLarge)
                                .foregroundColor(theme.colors.textPrimary)
                            
                            Text("Версия \(appVersion) (\(buildNumber))")
                                .textStyle(.bodyMedium)
                                .foregroundColor(theme.colors.textSecondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.vertical, theme.spacing.lg)
            }
            
            // Team Section
            Section {
                ForEach(teamInfo, id: \.0) { info in
                    HStack {
                        Text(info.0)
                            .textStyle(.bodyMedium)
                            .foregroundColor(theme.colors.textSecondary)
                        
                        Spacer()
                        
                        Text(info.1)
                            .textStyle(.bodyMedium)
                            .foregroundColor(theme.colors.textPrimary)
                    }
                }
            } header: {
                Text("Информация")
                    .textStyle(.labelMedium)
                    .foregroundColor(theme.colors.textSecondary)
                    .textCase(.uppercase)
            }
            
            // Links Section
            Section {
                Button {
                    // TODO: Open privacy policy
                } label: {
                    HStack {
                        Text("Политика конфиденциальности")
                            .textStyle(.bodyMedium)
                            .foregroundColor(theme.colors.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 16))
                            .foregroundColor(Color.accentColor)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Button {
                    // TODO: Open terms
                } label: {
                    HStack {
                        Text("Условия использования")
                            .textStyle(.bodyMedium)
                            .foregroundColor(theme.colors.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 16))
                            .foregroundColor(Color.accentColor)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Button {
                    // TODO: Contact support
                } label: {
                    HStack {
                        Text("Связаться с поддержкой")
                            .textStyle(.bodyMedium)
                            .foregroundColor(theme.colors.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "envelope")
                            .font(.system(size: 16))
                            .foregroundColor(Color.accentColor)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            } header: {
                Text("Правовая информация")
                    .textStyle(.labelMedium)
                    .foregroundColor(theme.colors.textSecondary)
                    .textCase(.uppercase)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(theme.colors.background)
        .navigationTitle("О приложении")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Reusable Settings Components
struct SettingsTextField: View {
    @Environment(\.theme) private var theme
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(title)
                .textStyle(.labelMedium)
                .foregroundColor(theme.colors.textSecondary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(theme.typography.bodyMedium)
                .foregroundColor(theme.colors.textPrimary)
                .padding(.horizontal, theme.spacing.md)
                .padding(.vertical, theme.spacing.sm)
                .background(theme.colors.surface)
                .cornerRadius(theme.radius.sm)
        }
    }
}

struct SettingsPicker: View {
    @Environment(\.theme) private var theme
    let title: String
    @Binding var selection: String
    let options: [String]
    
    var body: some View {
        HStack {
            Text(title)
                .textStyle(.bodyMedium)
                .foregroundColor(theme.colors.textPrimary)
            
            Spacer()
            
            Picker(title, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.menu)
            .foregroundColor(Color.accentColor)
        }
    }
}

struct SettingsToggle: View {
    @Environment(\.theme) private var theme
    let title: String
    @Binding var isOn: Bool
    let subtitle: String?
    
    init(title: String, isOn: Binding<Bool>, subtitle: String? = nil) {
        self.title = title
        self._isOn = isOn
        self.subtitle = subtitle
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(title)
                    .textStyle(.bodyMedium)
                    .foregroundColor(theme.colors.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .textStyle(.caption)
                        .foregroundColor(theme.colors.textSecondary)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
    }
}

struct SettingsTimePicker: View {
    @Environment(\.theme) private var theme
    let title: String
    @Binding var time: Date
    
    var body: some View {
        HStack {
            Text(title)
                .textStyle(.bodyMedium)
                .foregroundColor(theme.colors.textPrimary)
            
            Spacer()
            
            DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .foregroundColor(Color.accentColor)
        }
    }
}

#Preview("Profile") {
    ThemeProvider {
        NavigationStack {
            ProfileSettingsView()
        }
    }
}

#Preview("Notifications") {
    ThemeProvider {
        NavigationStack {
            NotificationSettingsView()
        }
    }
}

#Preview("Security") {
    ThemeProvider {
        NavigationStack {
            SecuritySettingsView()
        }
    }
}

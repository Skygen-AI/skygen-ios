//
//  IntegrationsView.swift
//  SkyGen
//
//  Integrations tab view with detailed integration management
//

import SwiftUI

struct IntegrationsView: View {
    @Environment(\.theme) private var theme
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @StateObject private var mockData = MockDataManager.shared
    
    @State private var searchText = ""
    @State private var selectedStatus: MockIntegration.ConnectionStatus? = nil
    @State private var showAddIntegrationSheet = false
    
    private var filteredIntegrations: [MockIntegration] {
        let integrations = mockData.getIntegrations()
        
        var filtered = integrations
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { integration in
                integration.name.localizedCaseInsensitiveContains(searchText) ||
                integration.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by status
        if let selectedStatus = selectedStatus {
            filtered = filtered.filter { $0.status == selectedStatus }
        }
        
        return filtered.sorted { first, second in
            // Connected integrations first
            if first.status != second.status {
                return first.status == .connected
            }
            // Then by name
            return first.name < second.name
        }
    }
    
    private var statusCounts: [MockIntegration.ConnectionStatus: Int] {
        let integrations = mockData.getIntegrations()
        var counts: [MockIntegration.ConnectionStatus: Int] = [:]
        
        for status in MockIntegration.ConnectionStatus.allCases {
            counts[status] = integrations.filter { $0.status == status }.count
        }
        
        return counts
    }
    
    var body: some View {
        NavigationStack(path: $navigationRouter.integrationNavigationPath) {
            VStack(spacing: 0) {
                // Search bar
                SkySearchField(
                    searchText: $searchText,
                    placeholder: "Поиск интеграций..."
                )
                .padding(.horizontal, theme.spacing.screenPadding)
                .padding(.bottom, theme.spacing.sm)
                
                // Status filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.sm) {
                        IntegrationStatusFilterChip(
                            title: "Все",
                            count: mockData.getIntegrations().count,
                            isSelected: selectedStatus == nil
                        ) {
                            selectedStatus = nil
                        }
                        
                        ForEach(MockIntegration.ConnectionStatus.allCases, id: \.self) { status in
                            IntegrationStatusFilterChip(
                                title: status.rawValue,
                                count: statusCounts[status] ?? 0,
                                isSelected: selectedStatus == status,
                                statusColor: Color(status.color)
                            ) {
                                selectedStatus = status
                            }
                        }
                    }
                    .padding(.horizontal, theme.spacing.screenPadding)
                }
                .padding(.bottom, theme.spacing.sm)
                
                // Integrations list
                if filteredIntegrations.isEmpty {
                    if searchText.isEmpty {
                        // Empty state
                        SkyEmptyState(
                            icon: "link.circle",
                            title: "Нет интеграций",
                            message: "Подключите сервисы для расширения возможностей SkyGen",
                            actionTitle: "Добавить интеграцию",
                            action: {
                                showAddIntegrationSheet = true
                            }
                        )
                    } else {
                        // Search empty state
                        SkySearchEmptyState(searchQuery: searchText)
                    }
                } else {
                    List {
                        ForEach(filteredIntegrations) { integration in
                            IntegrationListItem(integration: integration) {
                                navigationRouter.integrationNavigationPath.append(
                                    IntegrationDestination.integrationDetail(id: integration.id)
                                )
                            }
                            .listRowBackground(theme.colors.background)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .padding(.horizontal, theme.spacing.screenPadding)
                            .padding(.vertical, theme.spacing.xs)
                        }
                    }
                    .listStyle(.plain)
                    .background(theme.colors.background)
                }
            }
            .background(theme.colors.background)
            .navigationTitle("Интеграции")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddIntegrationSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(Color.accentColor)
                    }
                }
            }
            .navigationDestination(for: IntegrationDestination.self) { destination in
                switch destination {
                case .integrationDetail(let id):
                    IntegrationDetailView(integrationId: id)
                case .integrationSettings(let id):
                    IntegrationSettingsView(integrationId: id)
                }
            }
        }
        .sheet(isPresented: $showAddIntegrationSheet) {
            AddIntegrationView()
        }
    }
}

// MARK: - Integration List Item
struct IntegrationListItem: View {
    @Environment(\.theme) private var theme
    let integration: MockIntegration
    let onTap: () -> Void
    
    var body: some View {
        SkyInteractiveCard(action: onTap, padding: theme.spacing.md) {
            HStack(spacing: theme.spacing.md) {
                // Integration icon
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: integration.icon)
                        .font(.system(size: 20))
                        .foregroundColor(statusColor)
                }
                
                // Integration info
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    HStack {
                        Text(integration.name)
                            .textStyle(.titleMedium)
                            .foregroundColor(theme.colors.textPrimary)
                        
                        Spacer()
                        
                        HStack(spacing: theme.spacing.xs) {
                            Circle()
                                .fill(statusColor)
                                .frame(width: 8, height: 8)
                            
                            Text(integration.status.rawValue)
                                .textStyle(.caption)
                                .foregroundColor(statusColor)
                        }
                    }
                    
                    Text(integration.description)
                        .textStyle(.bodySmall)
                        .foregroundColor(theme.colors.textSecondary)
                    
                    HStack {
                        Text("Доступ: \(integration.scope)")
                            .textStyle(.captionSmall)
                            .foregroundColor(theme.colors.textTertiary)
                        
                        Spacer()
                        
                        if let lastSync = integration.lastSync {
                            Text("Синхронизация: \(formatTimestamp(lastSync))")
                                .textStyle(.captionSmall)
                                .foregroundColor(theme.colors.textTertiary)
                        }
                    }
                }
            }
        }
    }
    
    private var statusColor: Color {
        switch integration.status.color {
        case "success": return theme.colors.success
        case "warning": return theme.colors.warning
        case "error": return theme.colors.error
        default: return theme.colors.textSecondary
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Status Filter Chip
struct IntegrationStatusFilterChip: View {
    @Environment(\.theme) private var theme
    let title: String
    let count: Int
    let isSelected: Bool
    var statusColor: Color? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: theme.spacing.xs) {
                if let statusColor = statusColor {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                }
                
                Text(title)
                    .textStyle(.labelSmall)
                    .foregroundColor(isSelected ? theme.colors.textPrimary : theme.colors.textSecondary)
                
                Text("(\(count))")
                    .textStyle(.labelSmall)
                    .foregroundColor(theme.colors.textTertiary)
            }
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.full)
                    .fill(isSelected ? Color.accentColor.opacity(0.2) : theme.colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radius.full)
                            .stroke(
                                isSelected ? Color.accentColor : theme.colors.border,
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(theme.motion.easing.standard, value: isSelected)
    }
}

// MARK: - Detail Views
struct IntegrationDetailView: View {
    let integrationId: String
    @Environment(\.theme) private var theme
    @StateObject private var mockData = MockDataManager.shared
    
    private var integration: MockIntegration? {
        mockData.getIntegration(id: integrationId)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                if let integration = integration {
                    // Integration Header
                    VStack(spacing: theme.spacing.md) {
                        Image(systemName: integration.icon)
                            .font(.system(size: 64))
                            .foregroundColor(statusColor)
                        
                        VStack(spacing: theme.spacing.xs) {
                            Text(integration.name)
                                .textStyle(.headlineLarge)
                                .foregroundColor(theme.colors.textPrimary)
                            
                            Text(integration.description)
                                .textStyle(.bodyMedium)
                                .foregroundColor(theme.colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        HStack(spacing: theme.spacing.xs) {
                            Circle()
                                .fill(statusColor)
                                .frame(width: 8, height: 8)
                            
                            Text(integration.status.rawValue)
                                .textStyle(.titleMedium)
                                .foregroundColor(statusColor)
                        }
                    }
                    
                    // Connection Actions
                    SkyCard {
                        VStack(alignment: .leading, spacing: theme.spacing.md) {
                            Text("Управление подключением")
                                .textStyle(.titleMedium)
                                .foregroundColor(theme.colors.textPrimary)
                            
                            VStack(spacing: theme.spacing.sm) {
                                if integration.status == .connected {
                                    Button("Отключить") {
                                        // TODO: Disconnect integration
                                    }
                                    .buttonStyle(SecondaryButtonStyle())
                                    
                                    Button("Переподключить") {
                                        // TODO: Reconnect integration
                                    }
                                    .buttonStyle(TertiaryButtonStyle())
                                } else if integration.status == .expired {
                                    Button("Обновить токен") {
                                        // TODO: Refresh token
                                    }
                                    .buttonStyle(PrimaryButtonStyle())
                                } else {
                                    Button("Подключить") {
                                        // TODO: Connect integration
                                    }
                                    .buttonStyle(PrimaryButtonStyle())
                                }
                            }
                        }
                    }
                    
                    // Integration Info
                    SkyCard {
                        VStack(alignment: .leading, spacing: theme.spacing.md) {
                            Text("Информация")
                                .textStyle(.titleMedium)
                                .foregroundColor(theme.colors.textPrimary)
                            
                            VStack(spacing: theme.spacing.sm) {
                                InfoRow(label: "Статус", value: integration.status.rawValue)
                                InfoRow(label: "Область доступа", value: integration.scope)
                                
                                if let lastSync = integration.lastSync {
                                    InfoRow(label: "Последняя синхронизация", value: formatDetailTimestamp(lastSync))
                                }
                                
                                if integration.status == .expired {
                                    InfoRow(label: "Токен истек", value: "Требуется обновление")
                                }
                            }
                        }
                    }
                    
                    // Permissions
                    SkyCard {
                        VStack(alignment: .leading, spacing: theme.spacing.md) {
                            Text("Разрешения")
                                .textStyle(.titleMedium)
                                .foregroundColor(theme.colors.textPrimary)
                            
                            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                ForEach(integration.permissions, id: \.self) { permission in
                                    HStack(spacing: theme.spacing.sm) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(theme.colors.success)
                                            .font(.system(size: 16))
                                        
                                        Text(permission)
                                            .textStyle(.bodySmall)
                                            .foregroundColor(theme.colors.textPrimary)
                                        
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                } else {
                    SkyEmptyState(
                        icon: "exclamationmark.triangle",
                        title: "Интеграция не найдена",
                        message: "Интеграция с ID \(integrationId) не существует"
                    )
                }
            }
            .padding(theme.spacing.screenPadding)
        }
        .background(theme.colors.background)
        .navigationTitle("Интеграция")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var statusColor: Color {
        guard let integration = integration else { return theme.colors.textSecondary }
        
        switch integration.status.color {
        case "success": return theme.colors.success
        case "warning": return theme.colors.warning
        case "error": return theme.colors.error
        default: return theme.colors.textSecondary
        }
    }
    
    private func formatDetailTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct IntegrationSettingsView: View {
    let integrationId: String
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(spacing: theme.spacing.lg) {
            Spacer()
            
            Text("Настройки интеграции: \(integrationId)")
                .textStyle(.headlineLarge)
                .foregroundColor(theme.colors.textPrimary)
            
            Text("Здесь будут настройки уровня доступа и разрешенных действий")
                .textStyle(.bodyMedium)
                .foregroundColor(theme.colors.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(theme.spacing.screenPadding)
        .background(theme.colors.background)
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AddIntegrationView: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: theme.spacing.lg) {
                Spacer()
                
                Text("Добавить интеграцию")
                    .textStyle(.headlineLarge)
                    .foregroundColor(theme.colors.textPrimary)
                
                Text("Здесь будет список доступных интеграций для подключения")
                    .textStyle(.bodyMedium)
                    .foregroundColor(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                Button("Подключить сервис") {
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(theme.spacing.screenPadding)
            .background(theme.colors.background)
            .navigationTitle("Новая интеграция")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(Color.accentColor)
                }
            }
        }
    }
}

#Preview {
    ThemeProvider {
        IntegrationsView()
            .environmentObject(NavigationRouter())
    }
}
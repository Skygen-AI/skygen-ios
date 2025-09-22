//
//  ActionsView.swift
//  SkyGen
//
//  Actions tab view with active actions management
//

import SwiftUI

struct ActionsView: View {
    @Environment(\.theme) private var theme
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @StateObject private var mockData = MockDataManager.shared
    
    @State private var searchText = ""
    @State private var selectedStatus: MockAction.ActionStatus? = nil
    @State private var showHistorySheet = false
    
    private var filteredActions: [MockAction] {
        let actions = mockData.getActions()
        
        var filtered = actions
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { action in
                action.title.localizedCaseInsensitiveContains(searchText) ||
                action.deviceName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by status
        if let selectedStatus = selectedStatus {
            filtered = filtered.filter { $0.status == selectedStatus }
        }
        
        return filtered.sorted { first, second in
            // Running actions first
            if first.status != second.status {
                return first.status == .running
            }
            // Then by start time (newest first)
            guard let firstStart = first.startTime, let secondStart = second.startTime else {
                return first.startTime != nil
            }
            return firstStart > secondStart
        }
    }
    
    private var statusCounts: [MockAction.ActionStatus: Int] {
        let actions = mockData.getActions()
        var counts: [MockAction.ActionStatus: Int] = [:]
        
        for status in MockAction.ActionStatus.allCases {
            counts[status] = actions.filter { $0.status == status }.count
        }
        
        return counts
    }
    
    var body: some View {
        NavigationStack(path: $navigationRouter.actionNavigationPath) {
            VStack(spacing: 0) {
                // Search bar
                SkySearchField(
                    searchText: $searchText,
                    placeholder: "Поиск действий..."
                )
                .padding(.horizontal, theme.spacing.screenPadding)
                .padding(.bottom, theme.spacing.sm)
                
                // Status filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.sm) {
                        ActionStatusFilterChip(
                            title: "Все",
                            count: mockData.getActions().count,
                            isSelected: selectedStatus == nil
                        ) {
                            selectedStatus = nil
                        }
                        
                        ForEach(MockAction.ActionStatus.allCases, id: \.self) { status in
                            ActionStatusFilterChip(
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
                
                // Actions list
                if filteredActions.isEmpty {
                    if searchText.isEmpty {
                        // Empty state
                        SkyEmptyState(
                            icon: "play.circle",
                            title: "Нет активных действий",
                            message: "Здесь отображаются выполняющиеся команды и их статусы",
                            actionTitle: "Просмотреть историю",
                            action: {
                                showHistorySheet = true
                            }
                        )
                    } else {
                        // Search empty state
                        SkySearchEmptyState(searchQuery: searchText)
                    }
                } else {
                    List {
                        ForEach(filteredActions) { action in
                            ActionListItem(action: action) {
                                navigationRouter.actionNavigationPath.append(
                                    ActionDestination.actionDetail(id: action.id)
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
            .navigationTitle("Действия")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showHistorySheet = true
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(Color.accentColor)
                    }
                }
            }
            .navigationDestination(for: ActionDestination.self) { destination in
                switch destination {
                case .actionDetail(let id):
                    ActionDetailView(actionId: id)
                case .actionHistory:
                    ActionHistoryView()
                }
            }
        }
        .sheet(isPresented: $showHistorySheet) {
            ActionHistoryView()
        }
    }
}

// MARK: - Action List Item
struct ActionListItem: View {
    @Environment(\.theme) private var theme
    let action: MockAction
    let onTap: () -> Void
    
    var body: some View {
        SkyInteractiveCard(action: onTap, padding: theme.spacing.md) {
            VStack(spacing: theme.spacing.sm) {
                // Header
                HStack(spacing: theme.spacing.md) {
                    // Status icon
                    ZStack {
                        Circle()
                            .fill(statusColor.opacity(0.1))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: action.status.icon)
                            .font(.system(size: 18))
                            .foregroundColor(statusColor)
                    }
                    
                    // Action info
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        HStack {
                            Text(action.title)
                                .textStyle(.titleMedium)
                                .foregroundColor(theme.colors.textPrimary)
                            
                            Spacer()
                            
                            Text(action.status.rawValue)
                                .textStyle(.caption)
                                .foregroundColor(statusColor)
                                .padding(.horizontal, theme.spacing.xs)
                                .padding(.vertical, 2)
                                .background(statusColor.opacity(0.1))
                                .cornerRadius(theme.radius.xs)
                        }
                        
                        Text("на \(action.deviceName)")
                            .textStyle(.bodySmall)
                            .foregroundColor(theme.colors.textSecondary)
                    }
                }
                
                // Progress bar (if running)
                if action.status == .running {
                    VStack(spacing: theme.spacing.xs) {
                        HStack {
                            Text("Прогресс")
                                .textStyle(.captionSmall)
                                .foregroundColor(theme.colors.textSecondary)
                            
                            Spacer()
                            
                            Text("\(Int(action.progress * 100))%")
                                .textStyle(.captionSmall)
                                .foregroundColor(theme.colors.textSecondary)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: theme.radius.xs)
                                    .fill(theme.colors.surface)
                                    .frame(height: 4)
                                
                                RoundedRectangle(cornerRadius: theme.radius.xs)
                                    .fill(statusColor)
                                    .frame(width: geometry.size.width * action.progress, height: 4)
                                    .animation(theme.motion.easing.standard, value: action.progress)
                            }
                        }
                        .frame(height: 4)
                    }
                }
                
                // Timestamps
                HStack {
                    if let startTime = action.startTime {
                        Text("Начато: \(formatTimestamp(startTime))")
                            .textStyle(.captionSmall)
                            .foregroundColor(theme.colors.textTertiary)
                    }
                    
                    Spacer()
                    
                    if let estimatedCompletion = action.estimatedCompletion {
                        Text("Завершение: \(formatTimestamp(estimatedCompletion))")
                            .textStyle(.captionSmall)
                            .foregroundColor(theme.colors.textTertiary)
                    }
                }
            }
        }
    }
    
    private var statusColor: Color {
        switch action.status.color {
        case "accent": return Color.accentColor
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
struct ActionStatusFilterChip: View {
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
struct ActionDetailView: View {
    let actionId: String
    @Environment(\.theme) private var theme
    @StateObject private var mockData = MockDataManager.shared
    
    private var action: MockAction? {
        mockData.getAction(id: actionId)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                if let action = action {
                    // Action Header
                    VStack(spacing: theme.spacing.md) {
                        Image(systemName: action.status.icon)
                            .font(.system(size: 64))
                            .foregroundColor(statusColor)
                        
                        VStack(spacing: theme.spacing.xs) {
                            Text(action.title)
                                .textStyle(.headlineLarge)
                                .foregroundColor(theme.colors.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text("на устройстве \(action.deviceName)")
                                .textStyle(.bodyMedium)
                                .foregroundColor(theme.colors.textSecondary)
                        }
                        
                        HStack(spacing: theme.spacing.xs) {
                            Circle()
                                .fill(statusColor)
                                .frame(width: 8, height: 8)
                            
                            Text(action.status.rawValue)
                                .textStyle(.titleMedium)
                                .foregroundColor(statusColor)
                        }
                    }
                    
                    // Progress (if running)
                    if action.status == .running {
                        SkyCard {
                            VStack(alignment: .leading, spacing: theme.spacing.md) {
                                HStack {
                                    Text("Прогресс выполнения")
                                        .textStyle(.titleMedium)
                                        .foregroundColor(theme.colors.textPrimary)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(action.progress * 100))%")
                                        .textStyle(.titleMedium)
                                        .foregroundColor(Color.accentColor)
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: theme.radius.sm)
                                            .fill(theme.colors.surface)
                                            .frame(height: 8)
                                        
                                        RoundedRectangle(cornerRadius: theme.radius.sm)
                                            .fill(Color.accentColor)
                                            .frame(width: geometry.size.width * action.progress, height: 8)
                                            .animation(theme.motion.easing.emphasized, value: action.progress)
                                    }
                                }
                                .frame(height: 8)
                            }
                        }
                    }
                    
                    // Action Controls
                    if action.status == .running {
                        SkyCard {
                            VStack(spacing: theme.spacing.md) {
                                Text("Управление")
                                    .textStyle(.titleMedium)
                                    .foregroundColor(theme.colors.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack(spacing: theme.spacing.md) {
                                    Button("Отменить") {
                                        // TODO: Cancel action
                                    }
                                    .buttonStyle(SecondaryButtonStyle())
                                    
                                    Button("Подробности") {
                                        // TODO: Show details
                                    }
                                    .buttonStyle(TertiaryButtonStyle())
                                }
                            }
                        }
                    } else if action.status == .failed {
                        SkyCard {
                            VStack(spacing: theme.spacing.md) {
                                Text("Действия")
                                    .textStyle(.titleMedium)
                                    .foregroundColor(theme.colors.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Button("Повторить") {
                                    // TODO: Retry action
                                }
                                .buttonStyle(PrimaryButtonStyle())
                            }
                        }
                    }
                    
                    // Action Info
                    SkyCard {
                        VStack(alignment: .leading, spacing: theme.spacing.md) {
                            Text("Информация")
                                .textStyle(.titleMedium)
                                .foregroundColor(theme.colors.textPrimary)
                            
                            VStack(spacing: theme.spacing.sm) {
                                if let startTime = action.startTime {
                                    InfoRow(label: "Начато", value: formatDetailTimestamp(startTime))
                                }
                                
                                if let estimatedCompletion = action.estimatedCompletion {
                                    InfoRow(label: "Ожидаемое завершение", value: formatDetailTimestamp(estimatedCompletion))
                                }
                                
                                InfoRow(label: "Статус", value: action.status.rawValue)
                                InfoRow(label: "Устройство", value: action.deviceName)
                                
                                if action.status == .running {
                                    InfoRow(label: "Прогресс", value: "\(Int(action.progress * 100))%")
                                }
                            }
                        }
                    }
                } else {
                    SkyEmptyState(
                        icon: "exclamationmark.triangle",
                        title: "Действие не найдено",
                        message: "Действие с ID \(actionId) не существует"
                    )
                }
            }
            .padding(theme.spacing.screenPadding)
        }
        .background(theme.colors.background)
        .navigationTitle("Действие")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var statusColor: Color {
        guard let action = action else { return theme.colors.textSecondary }
        
        switch action.status.color {
        case "accent": return Color.accentColor
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

struct ActionHistoryView: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: theme.spacing.lg) {
                Spacer()
                
                Text("История действий")
                    .textStyle(.headlineLarge)
                    .foregroundColor(theme.colors.textPrimary)
                
                Text("Здесь будет отображаться история всех выполненных действий")
                    .textStyle(.bodyMedium)
                    .foregroundColor(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding(theme.spacing.screenPadding)
            .background(theme.colors.background)
            .navigationTitle("История")
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
        ActionsView()
            .environmentObject(NavigationRouter())
    }
}

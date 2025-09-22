//
//  DevicesView.swift
//  SkyGen
//
//  Devices tab view with device management
//

import SwiftUI

struct DevicesView: View {
    @Environment(\.theme) private var theme
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @StateObject private var mockData = MockDataManager.shared
    
    @State private var searchText = ""
    @State private var selectedStatus: MockDevice.DeviceStatus? = nil
    @State private var showAddDeviceSheet = false
    
    private var filteredDevices: [MockDevice] {
        let devices = mockData.getDevices()
        
        var filtered = devices
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { device in
                device.name.localizedCaseInsensitiveContains(searchText) ||
                device.location.localizedCaseInsensitiveContains(searchText) ||
                device.ipAddress.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by status
        if let selectedStatus = selectedStatus {
            filtered = filtered.filter { $0.status == selectedStatus }
        }
        
        return filtered.sorted { first, second in
            // Online devices first
            if first.status != second.status {
                return first.status == .online
            }
            // Then by name
            return first.name < second.name
        }
    }
    
    private var statusCounts: [MockDevice.DeviceStatus: Int] {
        let devices = mockData.getDevices()
        var counts: [MockDevice.DeviceStatus: Int] = [:]
        
        for status in MockDevice.DeviceStatus.allCases {
            counts[status] = devices.filter { $0.status == status }.count
        }
        
        return counts
    }
    
    var body: some View {
        NavigationStack(path: $navigationRouter.deviceNavigationPath) {
            VStack(spacing: 0) {
                // Search bar
                SkySearchField(
                    searchText: $searchText,
                    placeholder: "Поиск устройств..."
                )
                .padding(.horizontal, theme.spacing.screenPadding)
                .padding(.bottom, theme.spacing.sm)
                
                // Status filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.sm) {
                        DeviceStatusFilterChip(
                            title: "Все",
                            count: mockData.getDevices().count,
                            isSelected: selectedStatus == nil
                        ) {
                            selectedStatus = nil
                        }
                        
                        ForEach(MockDevice.DeviceStatus.allCases, id: \.self) { status in
                            DeviceStatusFilterChip(
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
                
                // Device list
                if filteredDevices.isEmpty {
                    if searchText.isEmpty {
                        // Empty state
                        SkyEmptyState(
                            icon: "laptopcomputer.and.iphone",
                            title: "Нет устройств",
                            message: "Подключите устройства для управления ими через SkyGen",
                            actionTitle: "Добавить устройство",
                            action: {
                                showAddDeviceSheet = true
                            }
                        )
                    } else {
                        // Search empty state
                        SkySearchEmptyState(searchQuery: searchText)
                    }
                } else {
                    List {
                        ForEach(filteredDevices) { device in
                            DeviceListItem(device: device) {
                                navigationRouter.deviceNavigationPath.append(
                                    DeviceDestination.deviceDetail(id: device.id)
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
            .navigationTitle("Устройства")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddDeviceSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(Color.accentColor)
                    }
                }
            }
            .navigationDestination(for: DeviceDestination.self) { destination in
                switch destination {
                case .deviceDetail(let id):
                    DeviceDetailView(deviceId: id)
                case .deviceLogs(let id):
                    DeviceLogsView(deviceId: id)
                }
            }
        }
        .sheet(isPresented: $showAddDeviceSheet) {
            AddDeviceView()
        }
    }
}

// MARK: - Device List Item
struct DeviceListItem: View {
    @Environment(\.theme) private var theme
    let device: MockDevice
    let action: () -> Void
    
    var body: some View {
        SkyInteractiveCard(action: action, padding: theme.spacing.md) {
            HStack(spacing: theme.spacing.md) {
                // Device icon
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: device.type.icon)
                        .font(.system(size: 20))
                        .foregroundColor(statusColor)
                }
                
                // Device info
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    HStack {
                        Text(device.name)
                            .textStyle(.titleMedium)
                            .foregroundColor(theme.colors.textPrimary)
                        
                        Spacer()
                        
                        HStack(spacing: theme.spacing.xs) {
                            Circle()
                                .fill(statusColor)
                                .frame(width: 8, height: 8)
                            
                            Text(device.status.rawValue)
                                .textStyle(.caption)
                                .foregroundColor(statusColor)
                        }
                    }
                    
                    Text("\(device.type.rawValue) • \(device.version)")
                        .textStyle(.bodySmall)
                        .foregroundColor(theme.colors.textSecondary)
                    
                    HStack {
                        Text(device.location)
                            .textStyle(.captionSmall)
                            .foregroundColor(theme.colors.textTertiary)
                        
                        Spacer()
                        
                        Text("IP: \(device.ipAddress)")
                            .textStyle(.captionSmall)
                            .foregroundColor(theme.colors.textTertiary)
                    }
                    
                    Text("Последняя активность: \(formatTimestamp(device.lastSeen))")
                        .textStyle(.captionSmall)
                        .foregroundColor(theme.colors.textTertiary)
                }
            }
        }
    }
    
    private var statusColor: Color {
        switch device.status.color {
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
struct DeviceStatusFilterChip: View {
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

// MARK: - Placeholder Views
struct DeviceDetailView: View {
    let deviceId: String
    @Environment(\.theme) private var theme
    @StateObject private var mockData = MockDataManager.shared
    
    private var device: MockDevice? {
        mockData.getDevice(id: deviceId)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                if let device = device {
                    // Device Header
                    VStack(spacing: theme.spacing.md) {
                        Image(systemName: device.type.icon)
                            .font(.system(size: 64))
                            .foregroundColor(Color.accentColor)
                        
                        VStack(spacing: theme.spacing.xs) {
                            Text(device.name)
                                .textStyle(.headlineLarge)
                                .foregroundColor(theme.colors.textPrimary)
                            
                            Text("\(device.type.rawValue) • \(device.version)")
                                .textStyle(.bodyMedium)
                                .foregroundColor(theme.colors.textSecondary)
                        }
                        
                        HStack(spacing: theme.spacing.xs) {
                            Circle()
                                .fill(statusColor)
                                .frame(width: 8, height: 8)
                            
                            Text(device.status.rawValue)
                                .textStyle(.titleMedium)
                                .foregroundColor(statusColor)
                        }
                    }
                    
                    // Quick Actions
                    SkyCard {
                        VStack(alignment: .leading, spacing: theme.spacing.md) {
                            Text("Быстрые действия")
                                .textStyle(.titleMedium)
                                .foregroundColor(theme.colors.textPrimary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: theme.spacing.md) {
                                QuickActionButton(icon: "play.fill", title: "Запустить", action: {})
                                QuickActionButton(icon: "stop.fill", title: "Остановить", action: {})
                                QuickActionButton(icon: "arrow.clockwise", title: "Перезапустить", action: {})
                                QuickActionButton(icon: "arrow.down.circle", title: "Обновить", action: {})
                            }
                        }
                    }
                    
                    // Device Info
                    SkyCard {
                        VStack(alignment: .leading, spacing: theme.spacing.md) {
                            Text("Информация")
                                .textStyle(.titleMedium)
                                .foregroundColor(theme.colors.textPrimary)
                            
                            VStack(spacing: theme.spacing.sm) {
                                InfoRow(label: "IP адрес", value: device.ipAddress)
                                InfoRow(label: "Локация", value: device.location)
                                InfoRow(label: "Последняя активность", value: formatTimestamp(device.lastSeen))
                                InfoRow(label: "Версия ОС", value: device.version)
                            }
                        }
                    }
                } else {
                    SkyEmptyState(
                        icon: "exclamationmark.triangle",
                        title: "Устройство не найдено",
                        message: "Устройство с ID \(deviceId) не существует"
                    )
                }
            }
            .padding(theme.spacing.screenPadding)
        }
        .background(theme.colors.background)
        .navigationTitle("Устройство")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var statusColor: Color {
        guard let device = device else { return theme.colors.textSecondary }
        
        switch device.status.color {
        case "success": return theme.colors.success
        case "warning": return theme.colors.warning
        case "error": return theme.colors.error
        default: return theme.colors.textSecondary
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct QuickActionButton: View {
    @Environment(\.theme) private var theme
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: theme.spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(Color.accentColor)
                
                Text(title)
                    .textStyle(.labelSmall)
                    .foregroundColor(theme.colors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, theme.spacing.md)
            .background(theme.colors.surfaceElevated)
            .cornerRadius(theme.radius.sm)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct InfoRow: View {
    @Environment(\.theme) private var theme
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .textStyle(.bodySmall)
                .foregroundColor(theme.colors.textSecondary)
            
            Spacer()
            
            Text(value)
                .textStyle(.bodySmall)
                .foregroundColor(theme.colors.textPrimary)
        }
    }
}

struct DeviceLogsView: View {
    let deviceId: String
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(spacing: theme.spacing.lg) {
            Spacer()
            
            Text("Логи устройства: \(deviceId)")
                .textStyle(.headlineLarge)
                .foregroundColor(theme.colors.textPrimary)
            
            Text("Здесь будут отображаться логи устройства")
                .textStyle(.bodyMedium)
                .foregroundColor(theme.colors.textSecondary)
            
            Spacer()
        }
        .padding(theme.spacing.screenPadding)
        .background(theme.colors.background)
        .navigationTitle("Логи")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AddDeviceView: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: theme.spacing.lg) {
                Spacer()
                
                Text("Добавить устройство")
                    .textStyle(.headlineLarge)
                    .foregroundColor(theme.colors.textPrimary)
                
                Text("Здесь будет форма добавления нового устройства")
                    .textStyle(.bodyMedium)
                    .foregroundColor(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                Button("Добавить устройство") {
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(theme.spacing.screenPadding)
            .background(theme.colors.background)
            .navigationTitle("Новое устройство")
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
        DevicesView()
            .environmentObject(NavigationRouter())
    }
}

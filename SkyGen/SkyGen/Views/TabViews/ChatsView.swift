//
//  ChatsView.swift
//  SkyGen
//
//  Chats tab view with search and chat management
//

import SwiftUI

struct ChatsView: View {
    @Environment(\.theme) private var theme
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @StateObject private var mockData = MockDataManager.shared
    
    @State private var searchText = ""
    @State private var selectedFolder: String? = nil
    @State private var showNewChatSheet = false
    @State private var showFoldersManagement = false
    
    private var filteredChats: [MockChat] {
        let chats = mockData.getChats()
        
        var filtered = chats
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { chat in
                chat.title.localizedCaseInsensitiveContains(searchText) ||
                chat.lastMessage.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by folder
        if let selectedFolder = selectedFolder {
            filtered = filtered.filter { $0.folder == selectedFolder }
        }
        
        return filtered.sorted { first, second in
            // Pinned chats first
            if first.isPinned != second.isPinned {
                return first.isPinned
            }
            // Then by timestamp
            return first.timestamp > second.timestamp
        }
    }
    
    private var folders: [String] {
        Array(Set(mockData.getChats().compactMap { $0.folder })).sorted()
    }
    
    var body: some View {
        NavigationStack(path: $navigationRouter.chatNavigationPath) {
            VStack(spacing: 0) {
                // Search bar
                SkySearchField(
                    searchText: $searchText,
                    placeholder: "Поиск чатов..."
                )
                .padding(.horizontal, theme.spacing.screenPadding)
                .padding(.bottom, theme.spacing.sm)
                
                // Folder filter
                if !folders.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: theme.spacing.sm) {
                            FolderFilterChip(
                                title: "Все",
                                isSelected: selectedFolder == nil
                            ) {
                                selectedFolder = nil
                            }
                            
                            ForEach(folders, id: \.self) { folder in
                                FolderFilterChip(
                                    title: folder,
                                    isSelected: selectedFolder == folder
                                ) {
                                    selectedFolder = folder
                                }
                            }
                        }
                        .padding(.horizontal, theme.spacing.screenPadding)
                    }
                    .padding(.bottom, theme.spacing.sm)
                }
                
                // Chat list
                if filteredChats.isEmpty {
                    if searchText.isEmpty {
                        // Empty state
                        SkyEmptyState(
                            icon: "message.circle",
                            title: "Нет чатов",
                            message: "Начните новый разговор с SkyGen AI ассистентом",
                            actionTitle: "Создать чат",
                            action: {
                                showNewChatSheet = true
                            }
                        )
                    } else {
                        // Search empty state
                        SkySearchEmptyState(searchQuery: searchText)
                    }
                } else {
                    List {
                        ForEach(filteredChats) { chat in
                            ChatListItem(chat: chat) {
                                navigationRouter.chatNavigationPath.append(
                                    ChatDestination.chatDetail(id: chat.id)
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
            .navigationTitle("Чаты")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: theme.spacing.sm) {
                        Button {
                            showFoldersManagement = true
                        } label: {
                            Image(systemName: "folder.badge.gearshape")
                                .foregroundColor(Color.accentColor)
                        }
                        
                        Button {
                            showNewChatSheet = true
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(Color.accentColor)
                        }
                    }
                }
            }
            .navigationDestination(for: ChatDestination.self) { destination in
                switch destination {
                case .chatDetail(let id):
                    ChatDetailView(chatId: id)
                case .newChat:
                    NewChatView()
                }
            }
        }
        .sheet(isPresented: $showNewChatSheet) {
            NewChatView()
        }
        .sheet(isPresented: $showFoldersManagement) {
            ChatFoldersView()
        }
    }
}

// MARK: - Chat List Item
struct ChatListItem: View {
    @Environment(\.theme) private var theme
    let chat: MockChat
    let action: () -> Void
    
    var body: some View {
        SkyInteractiveCard(action: action, padding: theme.spacing.md) {
            HStack(spacing: theme.spacing.md) {
                // Chat avatar/icon
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "message.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color.accentColor)
                }
                
                // Chat info
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    HStack {
                        HStack(spacing: theme.spacing.xs) {
                            if chat.isPinned {
                                Image(systemName: "pin.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(theme.colors.warning)
                            }
                            
                            Text(chat.title)
                                .textStyle(.titleMedium)
                                .foregroundColor(theme.colors.textPrimary)
                        }
                        
                        Spacer()
                        
                        Text(formatTimestamp(chat.timestamp))
                            .textStyle(.caption)
                            .foregroundColor(theme.colors.textTertiary)
                    }
                    
                    Text(chat.lastMessage)
                        .textStyle(.bodySmall)
                        .foregroundColor(theme.colors.textSecondary)
                        .lineLimit(2)
                    
                    HStack {
                        if let folder = chat.folder {
                            Text(folder)
                                .textStyle(.captionSmall)
                                .foregroundColor(Color.accentColor)
                                .padding(.horizontal, theme.spacing.xs)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.1))
                                .cornerRadius(theme.radius.xs)
                        }
                        
                        Spacer()
                        
                        Text("\(chat.messageCount) сообщений")
                            .textStyle(.captionSmall)
                            .foregroundColor(theme.colors.textTertiary)
                    }
                }
            }
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Folder Filter Chip
struct FolderFilterChip: View {
    @Environment(\.theme) private var theme
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .textStyle(.labelSmall)
                .foregroundColor(isSelected ? theme.colors.textPrimary : theme.colors.textSecondary)
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
struct NewChatView: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: theme.spacing.lg) {
                Spacer()
                
                Text("Новый чат")
                    .textStyle(.headlineLarge)
                    .foregroundColor(theme.colors.textPrimary)
                
                Text("Здесь будет форма создания нового чата")
                    .textStyle(.bodyMedium)
                    .foregroundColor(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                Button("Создать чат") {
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(theme.spacing.screenPadding)
            .background(theme.colors.background)
            .navigationTitle("Новый чат")
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
        ChatsView()
            .environmentObject(NavigationRouter())
    }
}

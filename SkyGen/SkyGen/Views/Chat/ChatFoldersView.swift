import SwiftUI

struct ChatFoldersView: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @StateObject private var mockData = MockDataManager.shared
    
    @State private var folders: [ChatFolder] = []
    @State private var showingAddFolder = false
    @State private var editingFolder: ChatFolder?
    @State private var newFolderName = ""
    @State private var showingDeleteAlert = false
    @State private var folderToDelete: ChatFolder?
    @State private var toast: SkyToast?
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(folders) { folder in
                        FolderRow(
                            folder: folder,
                            onEdit: {
                                editingFolder = folder
                                newFolderName = folder.name
                            },
                            onDelete: {
                                folderToDelete = folder
                                showingDeleteAlert = true
                            }
                        )
                        .listRowBackground(theme.colors.surface)
                    }
                    .onMove(perform: moveFolders)
                } header: {
                    Text("Папки чатов")
                        .textStyle(.labelMedium)
                        .foregroundColor(theme.colors.textSecondary)
                        .textCase(.uppercase)
                }
                
                Section {
                    Button {
                        showingAddFolder = true
                        newFolderName = ""
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color.accentColor)
                                .font(.system(size: 20))
                            
                            Text("Создать папку")
                                .textStyle(.bodyMedium)
                                .foregroundColor(Color.accentColor)
                            
                            Spacer()
                        }
                        .padding(.vertical, theme.spacing.xs)
                    }
                    .listRowBackground(theme.colors.surface)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(theme.colors.background)
            .navigationTitle("Управление папками")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Готово") {
                        dismiss()
                    }
                    .foregroundColor(Color.accentColor)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                        .foregroundColor(Color.accentColor)
                }
            }
        }
        .onAppear {
            loadFolders()
        }
        .alert("Удалить папку?", isPresented: $showingDeleteAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) {
                if let folder = folderToDelete {
                    deleteFolder(folder)
                }
            }
        } message: {
            if let folder = folderToDelete {
                Text("Папка \"\(folder.name)\" будет удалена. Чаты из этой папки переместятся в \"Все чаты\".")
            }
        }
        .sheet(isPresented: $showingAddFolder) {
            FolderEditSheet(
                title: "Новая папка",
                folderName: $newFolderName,
                onSave: createFolder,
                onCancel: { showingAddFolder = false }
            )
        }
        .sheet(item: $editingFolder) { folder in
            FolderEditSheet(
                title: "Редактировать папку",
                folderName: $newFolderName,
                onSave: { updateFolder(folder) },
                onCancel: { editingFolder = nil }
            )
        }
        .toastOverlay(toast: $toast)
    }
    
    private func loadFolders() {
        folders = mockData.getChatFolders()
    }
    
    private func createFolder() {
        guard !newFolderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let folder = ChatFolder(
            id: UUID().uuidString,
            name: newFolderName.trimmingCharacters(in: .whitespacesAndNewlines),
            color: ChatFolder.Color.allCases.randomElement() ?? .blue,
            chatIds: []
        )
        
        folders.append(folder)
        mockData.addChatFolder(folder)
        
        showingAddFolder = false
        newFolderName = ""
        
        toast = SkyToast(
            message: "Папка \"\(folder.name)\" создана",
            style: .success,
            isPresented: .constant(true)
        )
        
        HapticFeedback.success()
    }
    
    private func updateFolder(_ folder: ChatFolder) {
        guard !newFolderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        if let index = folders.firstIndex(where: { $0.id == folder.id }) {
            folders[index].name = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
            mockData.updateChatFolder(folders[index])
        }
        
        editingFolder = nil
        newFolderName = ""
        
        toast = SkyToast(
            message: "Папка обновлена",
            style: .success,
            isPresented: .constant(true)
        )
        
        HapticFeedback.success()
    }
    
    private func deleteFolder(_ folder: ChatFolder) {
        folders.removeAll { $0.id == folder.id }
        mockData.deleteChatFolder(folder.id)
        
        folderToDelete = nil
        
        toast = SkyToast(
            message: "Папка \"\(folder.name)\" удалена",
            style: .info,
            isPresented: .constant(true)
        )
        
        HapticFeedback.medium()
    }
    
    private func moveFolders(from source: IndexSet, to destination: Int) {
        folders.move(fromOffsets: source, toOffset: destination)
        // Here you would update the order in your data store
        HapticFeedback.light()
    }
}

// MARK: - Folder Row
struct FolderRow: View {
    @Environment(\.theme) private var theme
    let folder: ChatFolder
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: theme.spacing.md) {
            // Color indicator
            Circle()
                .fill(folder.color.swiftUIColor)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(folder.name)
                    .textStyle(.bodyMedium)
                    .foregroundColor(theme.colors.textPrimary)
                
                Text("\(folder.chatIds.count) \(chatCountText)")
                    .textStyle(.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }
            
            Spacer()
            
            // Edit button
            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil")
                    .foregroundColor(theme.colors.textSecondary)
                    .font(.system(size: 16))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, theme.spacing.xs)
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Удалить") {
                onDelete()
            }
            .tint(theme.colors.error)
            
            Button("Изменить") {
                onEdit()
            }
            .tint(Color.accentColor)
        }
    }
    
    private var chatCountText: String {
        let count = folder.chatIds.count
        if count == 1 {
            return "чат"
        } else if count >= 2 && count <= 4 {
            return "чата"
        } else {
            return "чатов"
        }
    }
}

// MARK: - Folder Edit Sheet
struct FolderEditSheet: View {
    @Environment(\.theme) private var theme
    let title: String
    @Binding var folderName: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: theme.spacing.lg) {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    Text("Название папки")
                        .textStyle(.labelMedium)
                        .foregroundColor(theme.colors.textSecondary)
                    
                    SkyTextField(
                        title: "",
                        text: $folderName,
                        placeholder: "Введите название",
                        keyboardType: .default
                    )
                    .focused($isTextFieldFocused)
                }
                
                Spacer()
            }
            .padding(theme.spacing.screenPadding)
            .background(theme.colors.background)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Отмена") {
                        onCancel()
                    }
                    .foregroundColor(theme.colors.textSecondary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Сохранить") {
                        onSave()
                    }
                    .foregroundColor(Color.accentColor)
                    .disabled(folderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
}

// MARK: - Chat Folder Model Extensions
extension ChatFolder {
    enum Color: String, CaseIterable {
        case blue, green, orange, red, purple, pink, teal, indigo
        
        var swiftUIColor: SwiftUI.Color {
            switch self {
            case .blue: return .blue
            case .green: return .green
            case .orange: return .orange
            case .red: return .red
            case .purple: return .purple
            case .pink: return .pink
            case .teal: return .teal
            case .indigo: return .indigo
            }
        }
    }
}

// MARK: - MockData Extensions
extension MockDataManager {
    func getChatFolders() -> [ChatFolder] {
        return [
            ChatFolder(id: "folder-1", name: "Работа", color: .blue, chatIds: ["chat-1", "chat-3"]),
            ChatFolder(id: "folder-2", name: "Личное", color: .green, chatIds: ["chat-2"]),
            ChatFolder(id: "folder-3", name: "Проекты", color: .orange, chatIds: ["chat-4", "chat-5"])
        ]
    }
    
    func addChatFolder(_ folder: ChatFolder) {
        // В реальном приложении здесь была бы логика сохранения в Core Data или другое хранилище
        print("Added folder: \(folder.name)")
    }
    
    func updateChatFolder(_ folder: ChatFolder) {
        // В реальном приложении здесь была бы логика обновления
        print("Updated folder: \(folder.name)")
    }
    
    func deleteChatFolder(_ folderId: String) {
        // В реальном приложении здесь была бы логика удаления
        print("Deleted folder: \(folderId)")
    }
}

// MARK: - Chat Folder Model
struct ChatFolder: Identifiable {
    let id: String
    var name: String
    let color: Color
    var chatIds: [String]
}

#Preview {
    ThemeProvider {
        ChatFoldersView()
    }
}

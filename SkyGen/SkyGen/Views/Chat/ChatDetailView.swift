//
//  ChatDetailView.swift
//  SkyGen
//
//  Detailed chat view with messages
//

import SwiftUI

struct ChatDetailView: View {
    let chatId: String
    @Environment(\.theme) private var theme
    @StateObject private var mockData = MockDataManager.shared
    
    @State private var messageText = ""
    @State private var messages: [MockMessage] = []
    @State private var isLoading = false
    @FocusState private var isTextFieldFocused: Bool
    
    private var chat: MockChat? {
        mockData.getChat(id: chatId)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            ScrollViewReader { proxy in
                List {
                    ForEach(messages) { message in
                        MessageRow(message: message)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .id(message.id)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                }
                .listStyle(.plain)
                .background(theme.colors.background)
                .onChange(of: messages.count) { _ in
                    // Auto-scroll to bottom when new message added
                    if let lastMessage = messages.last {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Message input
            ChatInputView(
                messageText: $messageText,
                isLoading: $isLoading,
                isTextFieldFocused: $isTextFieldFocused,
                onSend: sendMessage
            )
        }
        .background(theme.colors.background)
        .navigationTitle(chat?.title ?? "Чат")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Очистить чат") {
                        clearChat()
                    }
                    
                    Button("Экспорт чата") {
                        exportChat()
                    }
                    
                    Button("Настройки чата") {
                        // TODO: Show chat settings
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(Color.accentColor)
                }
            }
        }
        .onAppear {
            loadMessages()
        }
    }
    
    private func loadMessages() {
        messages = mockData.getMessages(for: chatId)
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = MockMessage(
            id: UUID().uuidString,
            content: messageText,
            isFromUser: true,
            timestamp: Date(),
            type: .text
        )
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            messages.append(userMessage)
        }
        
        messageText = ""
        isLoading = true
        HapticFeedback.light()
        
        // Simulate AI response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let aiResponse = MockMessage(
                id: UUID().uuidString,
                content: generateAIResponse(to: userMessage.content),
                isFromUser: false,
                timestamp: Date(),
                type: .text
            )
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                messages.append(aiResponse)
            }
            isLoading = false
            HapticFeedback.success()
        }
    }
    
    private func generateAIResponse(to userMessage: String) -> String {
        let responses = [
            "Понял! Работаю над этим...",
            "Отлично! Сейчас проверю статус устройств.",
            "Хорошая идея! Могу помочь с настройкой.",
            "Анализирую данные... Вот что я нашел:",
            "Проверяю подключение к устройствам...",
            "Настраиваю автоматизацию по вашему запросу.",
            "Создаю новый сценарий для умного дома."
        ]
        
        // Simple keyword-based response selection
        let message = userMessage.lowercased()
        
        if message.contains("свет") || message.contains("лампа") {
            return "Проверяю состояние освещения... Все лампы работают нормально. Хотите создать сценарий управления освещением?"
        } else if message.contains("температура") || message.contains("термостат") {
            return "Текущая температура в доме: 22°C. Термостат работает в автоматическом режиме. Хотите изменить настройки?"
        } else if message.contains("устройства") || message.contains("девайс") {
            return "Показываю список ваших устройств:\n• 3 устройства онлайн\n• 1 устройство требует внимания\n\nХотите посмотреть подробности?"
        } else if message.contains("проблема") || message.contains("ошибка") {
            return "Диагностирую систему... Нашел несколько предупреждений. Запускаю автоматическое исправление."
        } else {
            return responses.randomElement() ?? responses[0]
        }
    }
    
    private func clearChat() {
        messages.removeAll()
    }
    
    private func exportChat() {
        // TODO: Implement chat export
    }
}

// MARK: - Message Row
struct MessageRow: View {
    @Environment(\.theme) private var theme
    let message: MockMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer(minLength: 50)
                UserMessageBubble(message: message)
            } else {
                AIMessageBubble(message: message)
                Spacer(minLength: 50)
            }
        }
        .padding(.horizontal, theme.spacing.screenPadding)
        .padding(.vertical, theme.spacing.xs)
    }
}

// MARK: - User Message Bubble
struct UserMessageBubble: View {
    @Environment(\.theme) private var theme
    let message: MockMessage
    
    var body: some View {
        VStack(alignment: .trailing, spacing: theme.spacing.xs) {
            HStack {
                Text(message.content)
                    .textStyle(.bodyMedium)
                    .foregroundColor(.white)
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.vertical, theme.spacing.sm)
                    .background(Color.accentColor)
                    .cornerRadius(theme.radius.lg, corners: [.topLeft, .topRight, .bottomLeft])
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Text(formatTimestamp(message.timestamp))
                .textStyle(.captionSmall)
                .foregroundColor(theme.colors.textTertiary)
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - AI Message Bubble
struct AIMessageBubble: View {
    @Environment(\.theme) private var theme
    let message: MockMessage
    
    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack {
                // AI Avatar
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 16))
                        .foregroundColor(Color.accentColor)
                }
                
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    if message.isLoading {
                        LoadingMessageBubble()
                    } else {
                        Text(message.content)
                            .textStyle(.bodyMedium)
                            .foregroundColor(theme.colors.textPrimary)
                            .padding(.horizontal, theme.spacing.md)
                            .padding(.vertical, theme.spacing.sm)
                            .background(theme.colors.surface)
                            .cornerRadius(theme.radius.lg, corners: [.topLeft, .topRight, .bottomRight])
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    if !message.isLoading {
                        HStack(spacing: theme.spacing.sm) {
                            Text(formatTimestamp(message.timestamp))
                                .textStyle(.captionSmall)
                                .foregroundColor(theme.colors.textTertiary)
                            
                            // Action buttons for AI messages
                            Button {
                                copyMessage()
                            } label: {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 12))
                                    .foregroundColor(theme.colors.textTertiary)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button {
                                regenerateResponse()
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 12))
                                    .foregroundColor(theme.colors.textTertiary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.leading, theme.spacing.md)
                    }
                }
                
                Spacer()
            }
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func copyMessage() {
        UIPasteboard.general.string = message.content
    }
    
    private func regenerateResponse() {
        // TODO: Implement regenerate
    }
}

// MARK: - Loading Message Bubble
struct LoadingMessageBubble: View {
    @Environment(\.theme) private var theme
    @State private var animationOffset: CGFloat = -1
    
    var body: some View {
        HStack(spacing: theme.spacing.xs) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(theme.colors.textTertiary)
                    .frame(width: 8, height: 8)
                    .scaleEffect(animationOffset == CGFloat(index) ? 1.2 : 0.8)
                    .animation(
                        Animation
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animationOffset
                    )
            }
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .background(theme.colors.surface)
        .cornerRadius(theme.radius.lg, corners: [.topLeft, .topRight, .bottomRight])
        .onAppear {
            animationOffset = 2
        }
    }
}

// MARK: - Chat Input View
struct ChatInputView: View {
    @Environment(\.theme) private var theme
    @Binding var messageText: String
    @Binding var isLoading: Bool
    @FocusState.Binding var isTextFieldFocused: Bool
    let onSend: () -> Void
    
    @State private var showAttachments = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Attachment options (if visible)
            if showAttachments {
                AttachmentOptionsView(onHide: { showAttachments = false })
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Input area
            HStack(spacing: theme.spacing.sm) {
                // Attachment button
                Button {
                    withAnimation(.spring()) {
                        showAttachments.toggle()
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(showAttachments ? Color.accentColor : theme.colors.textTertiary)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Text input
                HStack(spacing: theme.spacing.sm) {
                    TextField("Сообщение...", text: $messageText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .font(theme.typography.bodyMedium)
                        .focused($isTextFieldFocused)
                        .disabled(isLoading)
                        .lineLimit(1...6)
                    
                    if !messageText.isEmpty {
                        Button {
                            messageText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(theme.colors.textTertiary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, theme.spacing.md)
                .padding(.vertical, theme.spacing.sm)
                .background(theme.colors.surface)
                .cornerRadius(theme.radius.full)
                
                // Send button
                Button(action: onSend) {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .frame(width: 24, height: 24)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(messageText.isEmpty ? theme.colors.textTertiary : Color.accentColor)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(messageText.isEmpty || isLoading)
            }
            .padding(.horizontal, theme.spacing.screenPadding)
            .padding(.vertical, theme.spacing.sm)
            .background(theme.colors.background)
        }
    }
}

// MARK: - Attachment Options
struct AttachmentOptionsView: View {
    @Environment(\.theme) private var theme
    let onHide: () -> Void
    
    private let attachmentOptions = [
        ("camera.fill", "Камера", Color.blue),
        ("photo.fill", "Фото", Color.green),
        ("doc.fill", "Файл", Color.orange),
        ("mic.fill", "Голос", Color.red)
    ]
    
    var body: some View {
        VStack(spacing: theme.spacing.md) {
            HStack(spacing: theme.spacing.lg) {
                ForEach(attachmentOptions, id: \.0) { option in
                    AttachmentOptionButton(
                        icon: option.0,
                        title: option.1,
                        color: option.2,
                        onTap: {
                            handleAttachment(option.1)
                            onHide()
                        }
                    )
                }
                
                Spacer()
            }
            .padding(.horizontal, theme.spacing.screenPadding)
        }
        .padding(.vertical, theme.spacing.md)
        .background(theme.colors.surfaceElevated)
    }
    
    private func handleAttachment(_ type: String) {
        // TODO: Implement attachment handling
        print("Selected attachment type: \(type)")
    }
}

struct AttachmentOptionButton: View {
    @Environment(\.theme) private var theme
    let icon: String
    let title: String
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: theme.spacing.xs) {
            Button(action: onTap) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(title)
                .textStyle(.captionSmall)
                .foregroundColor(theme.colors.textSecondary)
        }
    }
}

// MARK: - Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ThemeProvider {
        NavigationStack {
            ChatDetailView(chatId: "chat-1")
        }
    }
}

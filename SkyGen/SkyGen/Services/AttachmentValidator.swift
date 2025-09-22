import Foundation
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Attachment Validator
class AttachmentValidator: ObservableObject {
    static let shared = AttachmentValidator()
    
    // MARK: - Limits Configuration
    struct Limits {
        static let maxFileSize: Int64 = 50 * 1024 * 1024 // 50 MB
        static let maxImageSize: Int64 = 10 * 1024 * 1024 // 10 MB
        static let maxVideoSize: Int64 = 100 * 1024 * 1024 // 100 MB
        static let maxAudioSize: Int64 = 25 * 1024 * 1024 // 25 MB
        static let maxAttachmentsPerMessage = 5
        static let maxTotalSizePerMessage: Int64 = 100 * 1024 * 1024 // 100 MB
        
        static let supportedImageTypes: Set<String> = ["public.image", "public.jpeg", "public.png", "public.gif", "public.heic"]
        static let supportedVideoTypes: Set<String> = ["public.movie", "public.video", "com.apple.quicktime-movie"]
        static let supportedAudioTypes: Set<String> = ["public.audio", "public.mp3", "com.apple.coreaudio-format"]
        static let supportedDocumentTypes: Set<String> = ["public.data", "public.content", "public.text", "com.adobe.pdf"]
    }
    
    // MARK: - Validation Result
    enum ValidationResult {
        case valid
        case fileTooLarge(currentSize: Int64, maxSize: Int64, filename: String)
        case unsupportedFileType(filename: String, type: String)
        case tooManyAttachments(current: Int, max: Int)
        case totalSizeTooLarge(currentSize: Int64, maxSize: Int64)
        case unknown(error: String)
        
        var isValid: Bool {
            if case .valid = self {
                return true
            }
            return false
        }
        
        var errorMessage: String {
            switch self {
            case .valid:
                return ""
            case .fileTooLarge(let currentSize, let maxSize, let filename):
                return "Файл \"\(filename)\" слишком большой (\(formatFileSize(currentSize)). Максимум: \(formatFileSize(maxSize))"
            case .unsupportedFileType(let filename, let type):
                return "Неподдерживаемый тип файла \"\(filename)\" (\(type))"
            case .tooManyAttachments(let current, let max):
                return "Слишком много вложений (\(current)/\(max)). Удалите некоторые файлы."
            case .totalSizeTooLarge(let currentSize, let maxSize):
                return "Общий размер вложений слишком большой (\(formatFileSize(currentSize)). Максимум: \(formatFileSize(maxSize))"
            case .unknown(let error):
                return "Ошибка: \(error)"
            }
        }
    }
    
    // MARK: - Attachment Info
    struct AttachmentInfo {
        let id: String
        let filename: String
        let size: Int64
        let type: UTType
        let data: Data?
        let url: URL?
        
        var fileExtension: String {
            return (filename as NSString).pathExtension.lowercased()
        }
        
        var isImage: Bool {
            return Limits.supportedImageTypes.contains(type.identifier) || 
                   ["jpg", "jpeg", "png", "gif", "heic", "webp"].contains(fileExtension)
        }
        
        var isVideo: Bool {
            return Limits.supportedVideoTypes.contains(type.identifier) || 
                   ["mp4", "mov", "avi", "mkv"].contains(fileExtension)
        }
        
        var isAudio: Bool {
            return Limits.supportedAudioTypes.contains(type.identifier) || 
                   ["mp3", "wav", "m4a", "aac"].contains(fileExtension)
        }
        
        var isDocument: Bool {
            return !isImage && !isVideo && !isAudio
        }
    }
    
    private init() {}
    
    // MARK: - Validation Methods
    func validateAttachment(_ attachment: AttachmentInfo) -> ValidationResult {
        // Check file size based on type
        let maxSize: Int64
        if attachment.isImage {
            maxSize = Limits.maxImageSize
        } else if attachment.isVideo {
            maxSize = Limits.maxVideoSize
        } else if attachment.isAudio {
            maxSize = Limits.maxAudioSize
        } else {
            maxSize = Limits.maxFileSize
        }
        
        if attachment.size > maxSize {
            return .fileTooLarge(currentSize: attachment.size, maxSize: maxSize, filename: attachment.filename)
        }
        
        // Check supported file types
        let isSupported = attachment.isImage || attachment.isVideo || attachment.isAudio || 
                         Limits.supportedDocumentTypes.contains(attachment.type.identifier)
        
        if !isSupported {
            return .unsupportedFileType(filename: attachment.filename, type: attachment.type.identifier)
        }
        
        return .valid
    }
    
    func validateAttachments(_ attachments: [AttachmentInfo]) -> ValidationResult {
        // Check number of attachments
        if attachments.count > Limits.maxAttachmentsPerMessage {
            return .tooManyAttachments(current: attachments.count, max: Limits.maxAttachmentsPerMessage)
        }
        
        // Check total size
        let totalSize = attachments.reduce(0) { $0 + $1.size }
        if totalSize > Limits.maxTotalSizePerMessage {
            return .totalSizeTooLarge(currentSize: totalSize, maxSize: Limits.maxTotalSizePerMessage)
        }
        
        // Validate each attachment individually
        for attachment in attachments {
            let result = validateAttachment(attachment)
            if !result.isValid {
                return result
            }
        }
        
        return .valid
    }
    
    // MARK: - Helper Methods
    func canAddMoreAttachments(currentCount: Int) -> Bool {
        return currentCount < Limits.maxAttachmentsPerMessage
    }
    
    func remainingAttachmentSlots(currentCount: Int) -> Int {
        return max(0, Limits.maxAttachmentsPerMessage - currentCount)
    }
    
    func getRemainingSize(currentTotalSize: Int64) -> Int64 {
        return max(0, Limits.maxTotalSizePerMessage - currentTotalSize)
    }
}

// MARK: - File Size Formatting
func formatFileSize(_ bytes: Int64) -> String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useKB, .useMB, .useGB]
    formatter.countStyle = .file
    return formatter.string(fromByteCount: bytes)
}

// MARK: - Attachment Validation UI Component
struct AttachmentValidationView: View {
    @Environment(\.theme) private var theme
    let validationResult: AttachmentValidator.ValidationResult
    
    var body: some View {
        if !validationResult.isValid {
            HStack(spacing: theme.spacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(theme.colors.warning)
                    .font(.system(size: 16))
                
                Text(validationResult.errorMessage)
                    .textStyle(.caption)
                    .foregroundColor(theme.colors.warning)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(theme.spacing.sm)
            .background(theme.colors.warning.opacity(0.1))
            .cornerRadius(theme.radius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.sm)
                    .stroke(theme.colors.warning.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Attachment Limits Info View
struct AttachmentLimitsInfoView: View {
    @Environment(\.theme) private var theme
    @Binding var isPresented: Bool
    
    var body: some View {
        SkyBottomSheet(isPresented: $isPresented) {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                Text("Лимиты вложений")
                    .textStyle(.titleLarge)
                    .foregroundColor(theme.colors.textPrimary)
                
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    LimitRow(
                        title: "Изображения",
                        limit: formatFileSize(AttachmentValidator.Limits.maxImageSize),
                        icon: "photo",
                        color: Color.accentColor
                    )
                    
                    LimitRow(
                        title: "Видео",
                        limit: formatFileSize(AttachmentValidator.Limits.maxVideoSize),
                        icon: "video",
                        color: .red
                    )
                    
                    LimitRow(
                        title: "Аудио",
                        limit: formatFileSize(AttachmentValidator.Limits.maxAudioSize),
                        icon: "waveform",
                        color: .green
                    )
                    
                    LimitRow(
                        title: "Документы",
                        limit: formatFileSize(AttachmentValidator.Limits.maxFileSize),
                        icon: "doc",
                        color: .orange
                    )
                    
                    Divider()
                        .background(theme.colors.border)
                    
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        Text("Общие ограничения")
                            .textStyle(.labelLarge)
                            .foregroundColor(theme.colors.textPrimary)
                        
                        Text("• Максимум \(AttachmentValidator.Limits.maxAttachmentsPerMessage) файлов в одном сообщении")
                            .textStyle(.bodyMedium)
                            .foregroundColor(theme.colors.textSecondary)
                        
                        Text("• Общий размер: до \(formatFileSize(AttachmentValidator.Limits.maxTotalSizePerMessage))")
                            .textStyle(.bodyMedium)
                            .foregroundColor(theme.colors.textSecondary)
                    }
                }
                
                Button("Понятно") {
                    isPresented = false
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, theme.spacing.md)
            }
        }
    }
}

// MARK: - Limit Row
struct LimitRow: View {
    @Environment(\.theme) private var theme
    let title: String
    let limit: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: theme.spacing.md) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 20))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(title)
                    .textStyle(.bodyMedium)
                    .foregroundColor(theme.colors.textPrimary)
                
                Text("до \(limit)")
                    .textStyle(.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ThemeProvider {
        VStack(spacing: 20) {
            AttachmentValidationView(
                validationResult: .fileTooLarge(
                    currentSize: 15 * 1024 * 1024,
                    maxSize: 10 * 1024 * 1024,
                    filename: "large_image.jpg"
                )
            )
            
            AttachmentValidationView(
                validationResult: .tooManyAttachments(current: 6, max: 5)
            )
            
            AttachmentLimitsInfoView(isPresented: .constant(true))
        }
        .padding()
        .background(Color(red: 32/255, green: 32/255, blue: 32/255))
    }
}

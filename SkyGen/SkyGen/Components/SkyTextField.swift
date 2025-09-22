//
//  SkyTextField.swift
//  SkyGen
//
//  Custom text field component with theme support
//

import SwiftUI

struct SkyTextField: View {
    @Environment(\.theme) private var theme
    
    let title: String
    @Binding var text: String
    let placeholder: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var isError: Bool = false
    var errorMessage: String? = nil
    var helperText: String? = nil
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            // Title
            if !title.isEmpty {
                Text(title)
                    .textStyle(.labelMedium)
                    .foregroundColor(theme.colors.textSecondary)
            }
            
            // Text Field
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .textFieldStyle(SkyTextFieldStyle(
                            isFocused: isFocused,
                            isError: isError
                        ))
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(autocapitalization)
                        .textFieldStyle(SkyTextFieldStyle(
                            isFocused: isFocused,
                            isError: isError
                        ))
                }
            }
            .focused($isFocused)
            .makeAccessible(
                label: title.isEmpty ? placeholder : title,
                hint: isError ? (errorMessage ?? "") : (helperText ?? ""),
                traits: .isSearchField
            )
            .minimumTouchTarget()
            
            // Helper/Error Text
            if let errorMessage = errorMessage, isError {
                Text(errorMessage)
                    .textStyle(.caption)
                    .foregroundColor(theme.colors.error)
            } else if let helperText = helperText {
                Text(helperText)
                    .textStyle(.caption)
                    .foregroundColor(theme.colors.textTertiary)
            }
        }
    }
}

struct SkyTextFieldStyle: TextFieldStyle {
    @Environment(\.theme) private var theme
    let isFocused: Bool
    let isError: Bool
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .textStyle(.bodyMedium)
            .foregroundColor(theme.colors.textPrimary)
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm + 2)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.textField)
                    .fill(theme.colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radius.textField)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
            )
            .animation(theme.motion.easing.standard, value: isFocused)
            .animation(theme.motion.easing.standard, value: isError)
    }
    
    private var borderColor: Color {
        if isError {
            return theme.colors.error
        } else if isFocused {
            return Color.accentColor
        } else {
            return theme.colors.border
        }
    }
    
    private var borderWidth: CGFloat {
        if isError || isFocused {
            return 2
        } else {
            return 1
        }
    }
}

// MARK: - OTP Code Field
struct SkyOTPField: View {
    @Environment(\.theme) private var theme
    @Binding var code: String
    let length: Int
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: theme.spacing.sm) {
            ForEach(0..<length, id: \.self) { index in
                Text(getDigit(at: index))
                    .textStyle(.headlineLarge)
                    .foregroundColor(theme.colors.textPrimary)
                    .frame(width: 48, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: theme.radius.textField)
                            .fill(theme.colors.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.radius.textField)
                                    .stroke(getBorderColor(for: index), lineWidth: getBorderWidth(for: index))
                            )
                    )
                    .animation(theme.motion.easing.standard, value: code)
                    .animation(theme.motion.easing.standard, value: isFocused)
            }
        }
        .overlay(
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .opacity(0)
                .focused($isFocused)
                .onChange(of: code) { newValue in
                    // Limit to specified length and numbers only
                    let filtered = String(newValue.prefix(length).filter { $0.isNumber })
                    if filtered != newValue {
                        code = filtered
                    }
                }
        )
        .onTapGesture {
            isFocused = true
        }
    }
    
    private func getDigit(at index: Int) -> String {
        guard index < code.count else { return "" }
        return String(code[code.index(code.startIndex, offsetBy: index)])
    }
    
    private func getBorderColor(for index: Int) -> Color {
        if isFocused && index == code.count {
            return Color.accentColor
        } else if index < code.count {
            return Color.accentColor.opacity(0.5)
        } else {
            return theme.colors.border
        }
    }
    
    private func getBorderWidth(for index: Int) -> CGFloat {
        if isFocused && index == code.count {
            return 2
        } else {
            return 1
        }
    }
}

// MARK: - Search Field
struct SkySearchField: View {
    @Environment(\.theme) private var theme
    @Binding var searchText: String
    let placeholder: String
    var onSearchSubmit: (() -> Void)? = nil
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: theme.spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(theme.colors.textTertiary)
            
            TextField(placeholder, text: $searchText)
                .textStyle(.bodyMedium)
                .foregroundColor(theme.colors.textPrimary)
                .focused($isFocused)
                .onSubmit {
                    onSearchSubmit?()
                }
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(theme.colors.textTertiary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.textField)
                .fill(theme.colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radius.textField)
                        .stroke(
                            isFocused ? Color.accentColor : theme.colors.border,
                            lineWidth: isFocused ? 2 : 1
                        )
                )
        )
        .animation(theme.motion.easing.standard, value: isFocused)
    }
}

#Preview("Text Field") {
    ThemeProvider {
        VStack(spacing: 20) {
            SkyTextField(
                title: "Email",
                text: .constant(""),
                placeholder: "Введите email"
            )
            
            SkyTextField(
                title: "Password",
                text: .constant(""),
                placeholder: "Введите пароль",
                isSecure: true
            )
            
            SkyTextField(
                title: "Error Field",
                text: .constant("invalid@"),
                placeholder: "Email",
                isError: true,
                errorMessage: "Некорректный email адрес"
            )
            
            SkyOTPField(
                code: .constant("123"),
                length: 6
            )
            
            SkySearchField(
                searchText: .constant(""),
                placeholder: "Поиск..."
            )
        }
        .padding()
        .background(Color.background)
    }
}

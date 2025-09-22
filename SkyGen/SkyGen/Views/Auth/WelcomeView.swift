//
//  WelcomeView.swift
//  SkyGen
//
//  Welcome screen with app introduction
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.theme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    let onGetStarted: () -> Void
    let onSAMLSSO: () -> Void
    
    // Состояния для анимации элементов UI
    @State private var imageAppeared = false
    @State private var textAppeared = false
    @State private var buttonAppeared = false
    @State private var showSignInOptions = false
    
    var body: some View {
        ZStack {
            // Background
            theme.colors.background
                .ignoresSafeArea()
            
            // Decorative animated lines
            AnimatedLinesBackground()
                .scaleEffect(1.5)
                .rotationEffect(.degrees(-30))
                .offset(x: 20, y: -85)
            
            // Затемнение при показе опций входа - с возможностью возврата
            if showSignInOptions {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            showSignInOptions = false
                        }
                    }
            }
            
            VStack {
                // Верхний spacer - исчезает в режиме Sign In
                if !showSignInOptions {
                    Spacer()
                }
                
                // Одна картинка - анимированно трансформируется (адаптивная к теме)
                Image(colorScheme == .dark ? "WelcomeIconDark" : "WelcomeIconLight")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: showSignInOptions ? 120 : 220, height: showSignInOptions ? 120 : 220)
                    .shadow(color: Color.black.opacity(0.8), radius: 60, x: 10, y: 25)
                    .scaleEffect(imageAppeared ? 1.0 : 0.3)
                    .opacity(imageAppeared ? 1.0 : 0.0)
                    .padding(.top, showSignInOptions ? theme.spacing.xl : 0)
                    .onTapGesture {
                        // Предотвращаем закрытие при тапе на картинку
                    }
                
                // Текст - остается и перемещается вместе с картинкой
                VStack(spacing: theme.spacing.xs) {
                    ZStack {
                        Text("Welcome to")
                            .font(.system(size: 32, weight: .medium, design: .default))
                            .foregroundColor(theme.colors.textSecondary)
                            .shadow(color: colorScheme == .dark ? Color.black.opacity(0.6): Color.white.opacity(0.6),
                                        radius: 30)
                            .opacity(showSignInOptions ? 0 : 1)
                            .scaleEffect(showSignInOptions ? 0.8 : 1.0)
                        
                        Text("Sign in to")
                            .font(.system(size: 32, weight: .medium, design: .default))
                            .foregroundColor(theme.colors.textSecondary)
                            .shadow(color: Color.black.opacity(0.6), radius: 30)
                            .opacity(showSignInOptions ? 1 : 0)
                            .scaleEffect(showSignInOptions ? 1.0 : 0.8)
                    }
                    
                    Text("Skygen")
                        .font(.system(size: 64, weight: .bold, design: .default))
                        .foregroundColor(theme.colors.textPrimary)
                        .shadow(color: colorScheme == .dark ? Color.black.opacity(0.6): Color.white.opacity(0.6),
                                    radius: 40)
                }
                .padding(.top, showSignInOptions ? 20 : 40)
                .offset(y: textAppeared ? 0 : 50)
                .opacity(textAppeared ? 1.0 : 0.0)
                .onTapGesture {
                    // Предотвращаем закрытие при тапе на текст
                }
                
                // Нижний spacer
                Spacer()
                
                // Кнопки входа или Get Started
                if showSignInOptions {
                    signInOptionsView
                } else {
                    Button("Get Started") {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            showSignInOptions = true
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, theme.spacing.screenPadding)
                    .padding(.bottom, theme.spacing.screenPadding)
                    .scaleEffect(buttonAppeared ? 1.0 : 0.8)
                    .opacity(buttonAppeared ? 1.0 : 0.0)
                }
            }
        }
        .onAppear {
            startUIAnimations()
        }
    }
    
    // MARK: - Sign In Options View
    private var signInOptionsView: some View {
        VStack(spacing: theme.spacing.md) {
            // Continue with Email
            Button(action: {
                // TODO: Navigate to email sign in
                onGetStarted()
            }) {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.white)
                    Text("Continue with Email")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(theme.colors.accent)
                .cornerRadius(theme.radius.button)
            }
            
            // Continue with Google
            Button(action: {
                // TODO: Google sign in
            }) {
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(.black)
                    Text("Continue with Google")
                        .foregroundColor(.black)
                        .font(.system(size: 16, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.white)
                .cornerRadius(theme.radius.button)
            }
            
            // SAML SSO
            Button(action: {
                onSAMLSSO()
            }) {
                HStack {
                    Image(systemName: "building.2.fill")
                        .foregroundColor(theme.colors.textSecondary)
                    Text("SAML SSO")
                        .foregroundColor(theme.colors.textSecondary)
                        .font(.system(size: 16, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(theme.colors.surface)
                .cornerRadius(theme.radius.button)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radius.button)
                        .stroke(theme.colors.border, lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, theme.spacing.screenPadding)
        .padding(.bottom, theme.spacing.screenPadding)
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        ))
        .onTapGesture {
            // Предотвращаем закрытие при тапе на область кнопок
        }
    }
    
    // MARK: - UI Animation Control
    private func startUIAnimations() {
        // Шаг 1: Картинка появляется первой
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 1.5)) {
                imageAppeared = true
            }
        }
        
        // Шаг 2: Текст появляется после картинки
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.easeInOut(duration: 1.0)) {
                textAppeared = true
            }
        }
        
        // Шаг 3: Фон запускается после текста (уже определен в AnimatedLinesBackground)
        
        // Шаг 4: Кнопка появляется на 2 секунды раньше
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation(.easeInOut(duration: 0.8)) {
                buttonAppeared = true
            }
        }
    }
}

// MARK: - Animated Lines Background Component
struct AnimatedLinesBackground: View {
    @Environment(\.theme) private var theme
    @State private var lineOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let lineSpacing: CGFloat = screenHeight / 14 // 14 линий на экран
            
            ForEach(0..<20, id: \.self) { index in
                AnimatedLine(
                    isEven: index % 2 == 0,
                    offset: lineOffset,
                    screenWidth: screenWidth
                )
                .position(
                    x: screenWidth / 2,
                    y: CGFloat(index) * lineSpacing + lineSpacing / 2
                )
            }
        }
        .onAppear {
            // Первый шаг: устанавливаем начальное значение
            lineOffset = -850
            
            // Первый шаг: от -750 до 250 за 5 секунд (запускается после текста)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 3.4)) {
                    lineOffset = -300
                }
                
                // Второй шаг: циклическая анимация от 250 до -300 и обратно
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeInOut(duration: 16).repeatForever(autoreverses: true)) {
                        lineOffset = 250
                    }
                }
            }
        }
        
    }
}

// MARK: - Single Animated Line Component
struct AnimatedLine: View {
    let isEven: Bool
    let offset: CGFloat
    let screenWidth: CGFloat
    @Environment(\.theme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    private let deviceIcons = [
        "iphone", "ipad", "macbook", "applewatch", "appletv",
        "airpods", "homepod", "camera", "display", "keyboard",
        "gamecontroller", "printer", "tv", "router", "cpu",
        "mouse", "headphones", "speaker.wave.3", "externaldrive", "internaldrive",
        "memorychip", "battery.100", "powercord", "cable.connector", "antenna.radiowaves.left.and.right",
        "iphone.gen1", "ipad.gen1", "macbook.gen1", "imac", "mac.studio",
        "airpods.pro", "beats.headphones", "ipod", "apple.logo", "finder",
        "safari", "mail", "messages", "facetime", "phone", "photos",
        "music", "app.store", "network", "wifi", "airtag", "scanner"
    ]
    
    // Создаем рандомный массив иконок для каждой линии
    @State private var randomizedIcons: [String] = []
    
    // Адаптивный цвет иконок для разных тем
    private var adaptiveIconColor: Color {
        // Используем SwiftUI colorScheme из Environment
        if colorScheme == .light {
            // В светлой теме - черный с большей непрозрачностью
            return Color.black.opacity(0.9)
        } else {
            // В темной теме - белый с меньшей непрозрачностью
            return Color.white.opacity(0.3)
        }
    }
    
    var body: some View {
        let xOffset = isEven ? -offset : offset
        
        return ZStack {
            // Первая копия линии
            createIconLine()
                .offset(x: xOffset)
            
            // Вторая копия для непрерывности
            createIconLine()
                .offset(
                    x: xOffset + (isEven ? screenWidth * 3.0 : -screenWidth * 3.0)
                )
            
            // Третья копия для непрерывности
            createIconLine()
                .offset(
                    x: xOffset + (isEven ? screenWidth * 6.0 : -screenWidth * 6.0)
                )
        }
        .opacity(0.2)
        .clipped()
        .onAppear {
            // Создаем уникальный рандомный массив иконок без дубликатов
            var shuffledIcons = deviceIcons.shuffled()
            
            // Если нужно больше иконок чем есть в пуле, дублируем массив
            while shuffledIcons.count < 30 {
                shuffledIcons += deviceIcons.shuffled()
            }
            
            // Берем первые 30 уникальных иконок
            randomizedIcons = Array(shuffledIcons.prefix(30))
        }
    }
    
    private func createIconLine() -> some View {
        HStack(spacing: 10) {
            ForEach(0..<30, id: \.self) { iconIndex in
                if !randomizedIcons.isEmpty {
                Image(systemName: randomizedIcons[iconIndex % randomizedIcons.count])
                    .font(.system(size: 24, weight: .ultraLight))
                    .foregroundColor(adaptiveIconColor)
                }
            }
        }
    }
}

#Preview {
    ThemeProvider {
        WelcomeView(
            onGetStarted: {
                print("Get Started tapped")
            },
            onSAMLSSO: {
                print("SAML SSO tapped")
            }
        )
    }
}

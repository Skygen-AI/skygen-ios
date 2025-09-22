//
//  MainTabView.swift
//  SkyGen
//
//  Main tab navigation view
//

import SwiftUI

struct MainTabView: View {
    @Environment(\.theme) private var theme
    @StateObject private var deepLinkManager = DeepLinkManager()
    @StateObject private var navigationRouter = NavigationRouter()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ChatsView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "message.circle.fill" : "message.circle")
                    Text("Чаты")
                }
                .tag(0)
            
            DevicesView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "laptopcomputer.and.iphone" : "laptopcomputer.and.iphone")
                    Text("Устройства")
                }
                .tag(1)
            
            ActionsView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "play.circle.fill" : "play.circle")
                    Text("Действия")
                }
                .tag(2)
            
            IntegrationsView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "link.circle.fill" : "link.circle")
                    Text("Интеграции")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "gearshape.fill" : "gearshape")
                    Text("Настройки")
                }
                .tag(4)
        }
        .accentColor(Color.accentColor)
        .preferredColorScheme(.dark)
        .environmentObject(deepLinkManager)
        .environmentObject(navigationRouter)
        .onChange(of: deepLinkManager.selectedTab) { newTab in
            selectedTab = newTab
        }
        .onChange(of: deepLinkManager.pendingDeepLink) { deepLink in
            if let deepLink = deepLink {
                navigationRouter.handleDeepLink(deepLink)
            }
        }
            .onOpenURL { url in
                deepLinkManager.handleURL(url)
            }
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(theme.colors.surface)
            
            // Normal state
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(theme.colors.textTertiary)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(theme.colors.textTertiary),
                .font: UIFont.systemFont(ofSize: 10, weight: .medium)
            ]
            
            // Selected state
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.accentColor)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(Color.accentColor),
                .font: UIFont.systemFont(ofSize: 10, weight: .medium)
            ]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    ThemeProvider {
        MainTabView()
    }
}

//
//  DeepLinkManager.swift
//  SkyGen
//
//  Deep link handling and navigation management
//

import SwiftUI
import Foundation

// MARK: - Deep Link Types
enum DeepLink: Equatable {
    case chat(id: String)
    case device(id: String)
    case action(id: String)
    case integration(id: String)
    case settings
    case profile
    case security
    case help
    case unknown(url: String)
    
    var tabIndex: Int {
        switch self {
        case .chat: return 0
        case .device: return 1
        case .action: return 2
        case .integration: return 3
        case .settings, .profile, .security, .help: return 4
        case .unknown: return 0
        }
    }
}

// MARK: - Deep Link Manager
@MainActor
class DeepLinkManager: ObservableObject {
    @Published var pendingDeepLink: DeepLink?
    @Published var selectedTab: Int = 0
    
    // Base URL scheme
    private let scheme = "skygen"
    
    // Parse URL into DeepLink
    func parseURL(_ url: URL) -> DeepLink? {
        guard url.scheme == scheme else {
            return .unknown(url: url.absoluteString)
        }
        
        let host = url.host
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        
        switch host {
        case "chat":
            if let id = pathComponents.first {
                return .chat(id: id)
            }
            return .chat(id: "new")
            
        case "device":
            if let id = pathComponents.first {
                return .device(id: id)
            }
            return .unknown(url: url.absoluteString)
            
        case "action":
            if let id = pathComponents.first {
                return .action(id: id)
            }
            return .unknown(url: url.absoluteString)
            
        case "integration":
            if let id = pathComponents.first {
                return .integration(id: id)
            }
            return .unknown(url: url.absoluteString)
            
        case "settings":
            if pathComponents.isEmpty {
                return .settings
            }
            
            switch pathComponents.first {
            case "profile":
                return .profile
            case "security":
                return .security
            case "help":
                return .help
            default:
                return .settings
            }
            
        default:
            return .unknown(url: url.absoluteString)
        }
    }
    
    // Handle incoming deep link
    func handleDeepLink(_ deepLink: DeepLink) {
        pendingDeepLink = deepLink
        selectedTab = deepLink.tabIndex
        
        // Clear pending link after a delay to allow navigation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pendingDeepLink = nil
        }
    }
    
    // Handle incoming URL
    func handleURL(_ url: URL) {
        if let deepLink = parseURL(url) {
            handleDeepLink(deepLink)
        }
    }
    
    // Generate URLs for sharing
    func generateURL(for deepLink: DeepLink) -> URL? {
        let baseURL = "\(scheme)://"
        
        let urlString: String
        switch deepLink {
        case .chat(let id):
            urlString = "\(baseURL)chat/\(id)"
        case .device(let id):
            urlString = "\(baseURL)device/\(id)"
        case .action(let id):
            urlString = "\(baseURL)action/\(id)"
        case .integration(let id):
            urlString = "\(baseURL)integration/\(id)"
        case .settings:
            urlString = "\(baseURL)settings"
        case .profile:
            urlString = "\(baseURL)settings/profile"
        case .security:
            urlString = "\(baseURL)settings/security"
        case .help:
            urlString = "\(baseURL)settings/help"
        case .unknown(let url):
            urlString = url
        }
        
        return URL(string: urlString)
    }
}

// MARK: - Navigation Router
@MainActor
class NavigationRouter: ObservableObject {
    @Published var chatNavigationPath = NavigationPath()
    @Published var deviceNavigationPath = NavigationPath()
    @Published var actionNavigationPath = NavigationPath()
    @Published var integrationNavigationPath = NavigationPath()
    @Published var settingsNavigationPath = NavigationPath()
    
    func handleDeepLink(_ deepLink: DeepLink) {
        // Clear all navigation paths first
        clearAllPaths()
        
        switch deepLink {
        case .chat(let id):
            if id != "new" {
                chatNavigationPath.append(ChatDestination.chatDetail(id: id))
            }
            
        case .device(let id):
            deviceNavigationPath.append(DeviceDestination.deviceDetail(id: id))
            
        case .action(let id):
            actionNavigationPath.append(ActionDestination.actionDetail(id: id))
            
        case .integration(let id):
            integrationNavigationPath.append(IntegrationDestination.integrationDetail(id: id))
            
        case .profile:
            settingsNavigationPath.append(SettingsDestination.profile)
            
        case .security:
            settingsNavigationPath.append(SettingsDestination.security)
            
        case .help:
            settingsNavigationPath.append(SettingsDestination.help)
            
        case .settings, .unknown:
            break // Stay on main settings screen
        }
    }
    
    private func clearAllPaths() {
        chatNavigationPath = NavigationPath()
        deviceNavigationPath = NavigationPath()
        actionNavigationPath = NavigationPath()
        integrationNavigationPath = NavigationPath()
        settingsNavigationPath = NavigationPath()
    }
}

// MARK: - Navigation Destinations
enum ChatDestination: Hashable {
    case chatDetail(id: String)
    case newChat
}

enum DeviceDestination: Hashable {
    case deviceDetail(id: String)
    case deviceLogs(id: String)
}

enum ActionDestination: Hashable {
    case actionDetail(id: String)
    case actionHistory
}

enum IntegrationDestination: Hashable {
    case integrationDetail(id: String)
    case integrationSettings(id: String)
}

enum SettingsDestination: Hashable {
    case profile
    case notifications
    case security
    case privacy
    case help
    case about
    case legal
}

//
//  SkyGenApp.swift
//  SkyGen
//
//  Created by Егор Андреевич on 19-09-2025.
//

import SwiftUI

@main
struct SkyGenApp: App {
    var body: some Scene {
        WindowGroup {
            ThemeProvider {
                RootView()
            }
        }
    }
}

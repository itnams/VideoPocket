//
//  Video_PocketApp.swift
//  Video Pocket
//
//  Created by Nam Nguyễn on 4/11/25.
//

import SwiftUI

@main
struct Video_PocketApp: App {
    @StateObject private var languageManager = LanguageManager.shared
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(languageManager)
        }
    }
}

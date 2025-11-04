//
//  LanguageManager.swift
//  Video Pocket
//
//  Created by Nam Nguyễn on 4/11/25.
//

import SwiftUI
import Combine

enum AppLanguage: String, CaseIterable {
    case vietnamese = "vi"
    case english = "en"
    
    var displayName: String {
        switch self {
        case .vietnamese:
            return "Tiếng Việt"
        case .english:
            return "English"
        }
    }
    
    var flag: String {
        switch self {
        case .vietnamese:
            return "🇻🇳"
        case .english:
            return "🇺🇸"
        }
    }
}

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "app_language")
            // Đánh dấu đã chọn ngôn ngữ
            UserDefaults.standard.set(true, forKey: "has_selected_language")
        }
    }
    
    var hasSelectedLanguage: Bool {
        UserDefaults.standard.bool(forKey: "has_selected_language")
    }
    
    private init() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "app_language"),
           let language = AppLanguage(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            // Mặc định là tiếng Việt nhưng chưa đánh dấu là đã chọn
            self.currentLanguage = .vietnamese
        }
    }
    
    func localizedString(_ key: String) -> String {
        switch currentLanguage {
        case .vietnamese:
            return LocalizedStrings.vietnamese[key] ?? key
        case .english:
            return LocalizedStrings.english[key] ?? key
        }
    }
}

struct LocalizedStrings {
    static let vietnamese: [String: String] = [
        // App
        "app_name": "Video Pocket",
        
        // ContentView
        "no_videos": "Chưa có video nào",
        "tap_to_add": "Nhấn nút + để thêm video mới",
        "add_first_video": "Thêm video đầu tiên",
        "youtube_video": "YouTube Video",
        
        // AddVideoView
        "add_video": "Thêm Video",
        "video_title": "Tiêu đề video",
        "video_url": "URL video",
        "add": "Thêm",
        "cancel": "Hủy",
        "invalid_url": "URL không hợp lệ",
        "enter_title": "Nhập tiêu đề",
        "enter_url": "Nhập URL",
        
        // VideoPlayerView
        "loading_video": "Đang tải video...",
        "error_loading": "Lỗi tải video",
        "unsupported_format": "Video không được hỗ trợ. Có thể video sử dụng codec không tương thích.",
        "tap_to_retry": "Chạm để thử lại",
        "close": "Đóng",
        
        // YouTubePlayerView
        "play_in_app": "Phát trong app",
        "open_youtube": "Mở trong YouTube App",
        "open_safari": "Mở trong Safari",
        
        // DownloadView
        "download_video": "Tải Video",
        "download_full": "Tải toàn bộ video",
        "download_audio": "Chỉ tải âm thanh",
        "downloading": "Đang tải...",
        "download_complete": "Tải thành công!",
        "download_failed": "Tải thất bại",
        "open_files": "Mở Files / Chia sẻ",
        "saved_in": "Đã lưu trong: Documents",
        "download_progress": "Tiến trình",
        
        // SettingsView
        "settings": "Cài đặt",
        "language": "Ngôn ngữ",
        "select_language": "Chọn ngôn ngữ",
        
        // SplashView
        "welcome": "Chào mừng",
        
        // LanguageSelectionView
        "select_language_title": "Chọn ngôn ngữ / Select Language",
        "select_language_subtitle": "Vui lòng chọn ngôn ngữ của bạn",
        "continue": "Tiếp tục"
    ]
    
    static let english: [String: String] = [
        // App
        "app_name": "Video Pocket",
        
        // ContentView
        "no_videos": "No videos yet",
        "tap_to_add": "Tap the + button to add a new video",
        "add_first_video": "Add First Video",
        "youtube_video": "YouTube Video",
        
        // AddVideoView
        "add_video": "Add Video",
        "video_title": "Video Title",
        "video_url": "Video URL",
        "add": "Add",
        "cancel": "Cancel",
        "invalid_url": "Invalid URL",
        "enter_title": "Enter title",
        "enter_url": "Enter URL",
        
        // VideoPlayerView
        "loading_video": "Loading video...",
        "error_loading": "Error loading video",
        "unsupported_format": "Video not supported. The video may use an incompatible codec.",
        "tap_to_retry": "Tap to retry",
        "close": "Close",
        
        // YouTubePlayerView
        "play_in_app": "Play in app",
        "open_youtube": "Open in YouTube App",
        "open_safari": "Open in Safari",
        
        // DownloadView
        "download_video": "Download Video",
        "download_full": "Download full video",
        "download_audio": "Download audio only",
        "downloading": "Downloading...",
        "download_complete": "Download complete!",
        "download_failed": "Download failed",
        "open_files": "Open Files / Share",
        "saved_in": "Saved in: Documents",
        "download_progress": "Progress",
        
        // SettingsView
        "settings": "Settings",
        "language": "Language",
        "select_language": "Select Language",
        
        // SplashView
        "welcome": "Welcome",
        
        // LanguageSelectionView
        "select_language_title": "Select Language / Chọn ngôn ngữ",
        "select_language_subtitle": "Please select your language",
        "continue": "Continue"
    ]
}

extension String {
    var localized: String {
        return LanguageManager.shared.localizedString(self)
    }
}


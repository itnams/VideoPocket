//
//  YouTubeHelper.swift
//  Video Pocket
//
//  Created by Nam Nguyễn on 4/11/25.
//

import Foundation

struct YouTubeHelper {
    /// Phát hiện xem URL có phải là YouTube URL không
    static func isYouTubeURL(_ urlString: String) -> Bool {
        let patterns = [
            "youtube.com/watch",
            "youtu.be/",
            "youtube.com/embed/",
            "youtube.com/v/",
            "m.youtube.com"
        ]
        
        return patterns.contains { urlString.contains($0) }
    }
    
    /// Trích xuất video ID từ YouTube URL
    static func extractVideoID(from urlString: String) -> String? {
        // Pattern 1: youtube.com/watch?v=VIDEO_ID
        if let url = URL(string: urlString),
           let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            if let videoID = queryItems.first(where: { $0.name == "v" })?.value {
                return videoID
            }
        }
        
        // Pattern 2: youtu.be/VIDEO_ID
        if urlString.contains("youtu.be/") {
            let components = urlString.components(separatedBy: "youtu.be/")
            if components.count > 1 {
                let videoID = components[1].components(separatedBy: "?")[0].components(separatedBy: "&")[0]
                return videoID
            }
        }
        
        // Pattern 3: youtube.com/embed/VIDEO_ID
        if urlString.contains("youtube.com/embed/") {
            let components = urlString.components(separatedBy: "youtube.com/embed/")
            if components.count > 1 {
                let videoID = components[1].components(separatedBy: "?")[0].components(separatedBy: "&")[0]
                return videoID
            }
        }
        
        // Pattern 4: youtube.com/v/VIDEO_ID
        if urlString.contains("youtube.com/v/") {
            let components = urlString.components(separatedBy: "youtube.com/v/")
            if components.count > 1 {
                let videoID = components[1].components(separatedBy: "?")[0].components(separatedBy: "&")[0]
                return videoID
            }
        }
        
        return nil
    }
    
    /// Tạo YouTube embed URL
    static func createEmbedURL(videoID: String) -> String {
        return "https://www.youtube.com/embed/\(videoID)?playsinline=1"
    }
    
    /// Tạo YouTube app URL scheme
    static func createYouTubeAppURL(videoID: String) -> URL? {
        return URL(string: "youtube://watch?v=\(videoID)")
    }
    
    /// Tạo YouTube web URL
    static func createYouTubeWebURL(videoID: String) -> URL? {
        return URL(string: "https://www.youtube.com/watch?v=\(videoID)")
    }
}


//
//  VideoStore.swift
//  Video Pocket
//
//  Created by Nam Nguyễn on 4/11/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class VideoStore: ObservableObject {
    @Published var videos: [Video] = []
    
    private let saveKey = "SavedVideos"
    
    init() {
        loadVideos()
    }
    
    func addVideo(urlString: String, title: String) {
        let video = Video(title: title.isEmpty ? urlString : title, urlString: urlString)
        videos.append(video)
        saveVideos()
    }
    
    func deleteVideo(at offsets: IndexSet) {
        // Xóa thumbnail cache trước khi xóa video
        for index in offsets {
            let video = videos[index]
            deleteThumbnailCache(for: video)
        }
        videos.remove(atOffsets: offsets)
        saveVideos()
    }
    
    func deleteVideo(_ video: Video) {
        deleteThumbnailCache(for: video)
        videos.removeAll { $0.id == video.id }
        saveVideos()
    }
    
    private func deleteThumbnailCache(for video: Video) {
        let cacheKey: String
        if YouTubeHelper.isYouTubeURL(video.urlString),
           let videoID = YouTubeHelper.extractVideoID(from: video.urlString) {
            cacheKey = "youtube_\(videoID)"
        } else {
            cacheKey = video.id.uuidString
        }
        ThumbnailCache.shared.deleteThumbnail(for: cacheKey)
    }
    
    private func saveVideos() {
        if let encoded = try? JSONEncoder().encode(videos) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadVideos() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Video].self, from: data) {
            videos = decoded
        }
    }
}


//
//  VideoThumbnailView.swift
//  Video Pocket
//
//  Created by Nam Nguyễn on 4/11/25.
//

import SwiftUI
import AVFoundation
import UIKit

class ThumbnailCache {
    static let shared = ThumbnailCache()
    
    private let cacheDirectory: URL
    
    private init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        cacheDirectory = documentsPath.appendingPathComponent("VideoThumbnails")
        
        // Tạo thư mục cache nếu chưa có
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func cachePath(for videoID: String) -> URL {
        cacheDirectory.appendingPathComponent("\(videoID).jpg")
    }
    
    func loadThumbnail(for videoID: String) -> UIImage? {
        let path = cachePath(for: videoID)
        guard let data = try? Data(contentsOf: path),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }
    
    func saveThumbnail(_ image: UIImage, for videoID: String) {
        let path = cachePath(for: videoID)
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: path)
        }
    }
    
    func deleteThumbnail(for videoID: String) {
        let path = cachePath(for: videoID)
        try? FileManager.default.removeItem(at: path)
    }
    
    func clearAll() {
        try? FileManager.default.removeItem(at: cacheDirectory)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}

struct VideoThumbnailView: View {
    let video: Video
    @State private var thumbnail: UIImage?
    @State private var isLoading = true
    
    private var cacheKey: String {
        if YouTubeHelper.isYouTubeURL(video.urlString),
           let videoID = YouTubeHelper.extractVideoID(from: video.urlString) {
            return "youtube_\(videoID)"
        }
        return video.id.uuidString
    }
    
    var body: some View {
        Group {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if isLoading {
                // Placeholder while loading
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                    if YouTubeHelper.isYouTubeURL(video.urlString) {
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.red)
                    } else {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
            } else {
                // Fallback icon
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                    if YouTubeHelper.isYouTubeURL(video.urlString) {
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.red)
                    } else {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .frame(width: 60, height: 60)
        .cornerRadius(8)
        .clipped()
        .onAppear {
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        // Kiểm tra cache trước
        if let cachedThumbnail = ThumbnailCache.shared.loadThumbnail(for: cacheKey) {
            thumbnail = cachedThumbnail
            isLoading = false
            return
        }
        
        // Nếu không có trong cache, load mới
        if YouTubeHelper.isYouTubeURL(video.urlString),
           let videoID = YouTubeHelper.extractVideoID(from: video.urlString) {
            loadYouTubeThumbnail(videoID: videoID)
            return
        }
        
        // Regular video thumbnail
        guard let url = video.url else {
            isLoading = false
            return
        }
        
        Task {
            await generateThumbnail(from: url)
        }
    }
    
    private func loadYouTubeThumbnail(videoID: String) {
        // YouTube thumbnail URL: https://img.youtube.com/vi/VIDEO_ID/0.jpg
        // 0 = highest quality, 1 = medium quality, 2 = low quality, 3 = default
        let thumbnailURL = "https://img.youtube.com/vi/\(videoID)/0.jpg"
        
        guard let url = URL(string: thumbnailURL) else {
            isLoading = false
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.thumbnail = image
                        self.isLoading = false
                        // Lưu vào cache
                        ThumbnailCache.shared.saveThumbnail(image, for: cacheKey)
                    }
                } else {
                    await MainActor.run {
                        self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    private func generateThumbnail(from url: URL) async {
        let asset = AVURLAsset(url: url)
        
        do {
            // Try to get thumbnail at 1 second
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            imageGenerator.requestedTimeToleranceAfter = .zero
            imageGenerator.requestedTimeToleranceBefore = .zero
            
            let time = CMTime(seconds: 1.0, preferredTimescale: 600)
            let cgImage = try await imageGenerator.image(at: time).image
            let image = UIImage(cgImage: cgImage)
            
            await MainActor.run {
                self.thumbnail = image
                self.isLoading = false
                // Lưu vào cache
                ThumbnailCache.shared.saveThumbnail(image, for: cacheKey)
            }
        } catch {
            // If 1 second fails, try 0.5 seconds
            do {
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                imageGenerator.appliesPreferredTrackTransform = true
                
                let time = CMTime(seconds: 0.5, preferredTimescale: 600)
                let cgImage = try await imageGenerator.image(at: time).image
                let image = UIImage(cgImage: cgImage)
                
                await MainActor.run {
                    self.thumbnail = image
                    self.isLoading = false
                    // Lưu vào cache
                    ThumbnailCache.shared.saveThumbnail(image, for: cacheKey)
                }
            } catch {
                // If all fails, try first frame
                do {
                    let imageGenerator = AVAssetImageGenerator(asset: asset)
                    imageGenerator.appliesPreferredTrackTransform = true
                    
                    let time = CMTime.zero
                    let cgImage = try await imageGenerator.image(at: time).image
                    let image = UIImage(cgImage: cgImage)
                    
                    await MainActor.run {
                        self.thumbnail = image
                        self.isLoading = false
                        // Lưu vào cache
                        ThumbnailCache.shared.saveThumbnail(image, for: cacheKey)
                    }
                } catch {
                    await MainActor.run {
                        self.isLoading = false
                    }
                }
            }
        }
    }
}


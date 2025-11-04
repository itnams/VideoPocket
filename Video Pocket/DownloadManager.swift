//
//  DownloadManager.swift
//  Video Pocket
//
//  Created by Nam Nguyễn on 4/11/25.
//

import Foundation
import AVFoundation
import Combine

enum DownloadType {
    case video
    case audioOnly
}

class DownloadManager: ObservableObject {
    static let shared = DownloadManager()
    
    @Published var isDownloading = false
    @Published var downloadProgress: Double = 0.0
    @Published var currentDownload: String?
    
    private let documentsDirectory: URL
    
    private init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func downloadVideo(url: URL, type: DownloadType, completion: @escaping (Result<URL, Error>) -> Void) {
        DispatchQueue.main.async {
            self.isDownloading = true
            self.downloadProgress = 0.0
            self.currentDownload = url.lastPathComponent
        }
        
        Task {
            do {
                let outputURL = try await performDownload(url: url, type: type)
                await MainActor.run {
                    self.isDownloading = false
                    self.downloadProgress = 1.0
                    self.currentDownload = nil
                }
                completion(.success(outputURL))
            } catch {
                await MainActor.run {
                    self.isDownloading = false
                    self.downloadProgress = 0.0
                    self.currentDownload = nil
                }
                completion(.failure(error))
            }
        }
    }
    
    private func performDownload(url: URL, type: DownloadType) async throws -> URL {
        // Tải file về với progress tracking
        let (asyncBytes, response) = try await URLSession.shared.bytes(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw DownloadError.invalidResponse
        }
        
        // Tạo file tạm
        let tempURL = documentsDirectory.appendingPathComponent(UUID().uuidString)
        FileManager.default.createFile(atPath: tempURL.path, contents: nil, attributes: nil)
        
        guard let fileHandle = try? FileHandle(forWritingTo: tempURL) else {
            throw DownloadError.exportFailed
        }
        defer { try? fileHandle.close() }
        
        var downloadedBytes: Int64 = 0
        let totalBytes = Int64(httpResponse.expectedContentLength)
        let hasContentLength = totalBytes > 0
        
        // Đọc và ghi dữ liệu với progress tracking
        // AsyncBytes trả về UInt8, cần collect thành Data
        var buffer = Data()
        let bufferSize = 1024 * 1024 // 1MB buffer
        
        for try await byte in asyncBytes {
            buffer.append(byte)
            
            // Ghi buffer khi đầy
            if buffer.count >= bufferSize {
                try fileHandle.write(contentsOf: buffer)
                downloadedBytes += Int64(buffer.count)
                buffer.removeAll(keepingCapacity: true)
                
                // Cập nhật progress nếu có Content-Length
                if hasContentLength {
                    await MainActor.run {
                        self.downloadProgress = Double(downloadedBytes) / Double(totalBytes)
                    }
                } else {
                    // Nếu không có Content-Length, chỉ hiển thị indeterminate progress
                    await MainActor.run {
                        self.downloadProgress = min(0.9, Double(downloadedBytes) / 1_000_000_000) // Giả định max 1GB
                    }
                }
            }
        }
        
        // Ghi phần còn lại
        if !buffer.isEmpty {
            try fileHandle.write(contentsOf: buffer)
            downloadedBytes += Int64(buffer.count)
        }
        
        // Tạo tên file
        let fileName = generateFileName(from: url, type: type)
        let outputURL = documentsDirectory.appendingPathComponent(fileName)
        
        // Xóa file cũ nếu đã tồn tại
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(at: outputURL)
        }
        
        if type == .audioOnly {
            // Extract audio từ video
            await MainActor.run {
                self.downloadProgress = 0.5 // 50% cho download, 50% cho export
            }
            try await extractAudio(from: tempURL, to: outputURL)
            // Xóa file video tạm
            try? FileManager.default.removeItem(at: tempURL)
        } else {
            // Di chuyển file video
            try FileManager.default.moveItem(at: tempURL, to: outputURL)
        }
        
        return outputURL
    }
    
    private func extractAudio(from videoURL: URL, to outputURL: URL) async throws {
        let asset = AVURLAsset(url: videoURL)
        
        // Đợi asset load metadata và tìm audio track
        let audioTracks = try await asset.load(.tracks)
        
        // Tìm audio track - mediaType là property có sẵn, không cần load
        let audioTrack = audioTracks.first { $0.mediaType == .audio }
        
        guard let audioTrack = audioTrack else {
            throw DownloadError.exportFailed
        }
        
        // Tạo composition chỉ với audio track
        let composition = AVMutableComposition()
        guard let compositionAudioTrack = composition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw DownloadError.exportFailed
        }
        
        // Thêm audio track vào composition
        // timeRange là property có sẵn, không cần load
        let audioTimeRange = audioTrack.timeRange
        try compositionAudioTrack.insertTimeRange(
            audioTimeRange,
            of: audioTrack,
            at: .zero
        )
        
        // Thử các preset theo thứ tự ưu tiên
        let presets = [
            AVAssetExportPresetAppleM4A,
            AVAssetExportPresetHighestQuality,
            AVAssetExportPresetMediumQuality,
            AVAssetExportPresetLowQuality
        ]
        
        var exportSession: AVAssetExportSession?
        var lastError: Error?
        
        for preset in presets {
            if let session = AVAssetExportSession(asset: composition, presetName: preset) {
                // Kiểm tra xem preset có hỗ trợ export audio không
                // supportedFileTypes là property có sẵn
                if session.supportedFileTypes.contains(.m4a) {
                    exportSession = session
                    break
                }
            }
        }
        
        guard let exportSession = exportSession else {
            throw DownloadError.exportFailed
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .m4a
        
        // Monitor progress trong background
        let progressTask = Task {
            while !Task.isCancelled {
                let status = await exportSession.status
                if status == .waiting || status == .exporting {
                    await MainActor.run {
                        // Map từ 50% đến 100% (vì download đã chiếm 50%)
                        self.downloadProgress = 0.5 + (Double(exportSession.progress) * 0.5)
                    }
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
                } else {
                    break
                }
            }
        }
        
        // Export async
        await exportSession.export()
        progressTask.cancel()
        
        let finalStatus = await exportSession.status
        guard finalStatus == .completed else {
            if let error = exportSession.error {
                throw error
            }
            throw DownloadError.exportFailed
        }
    }
    
    private func generateFileName(from url: URL, type: DownloadType) -> String {
        let originalName = url.lastPathComponent
        let nameWithoutExtension = (originalName as NSString).deletingPathExtension
        
        if type == .audioOnly {
            return "\(nameWithoutExtension).m4a"
        } else {
            return originalName
        }
    }
    
    func getDownloadedFiles() -> [URL] {
        do {
            let files = try FileManager.default.contentsOfDirectory(
                at: documentsDirectory,
                includingPropertiesForKeys: [.fileSizeKey, .creationDateKey],
                options: .skipsHiddenFiles
            )
            return files.filter { url in
                let ext = url.pathExtension.lowercased()
                return ext == "mp4" || ext == "mov" || ext == "m4v" || ext == "m4a" || ext == "mp3"
            }
        } catch {
            return []
        }
    }
}

enum DownloadError: LocalizedError {
    case invalidResponse
    case exportFailed
    case fileNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Phản hồi từ server không hợp lệ"
        case .exportFailed:
            return "Không thể trích xuất âm thanh từ video"
        case .fileNotFound:
            return "Không tìm thấy file"
        }
    }
}


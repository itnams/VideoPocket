//
//  Video.swift
//  Video Pocket
//
//  Created by Nam Nguyễn on 4/11/25.
//

import Foundation

struct Video: Identifiable, Codable {
    let id: UUID
    var title: String
    var urlString: String
    var dateAdded: Date
    
    var url: URL? {
        URL(string: urlString)
    }
    
    init(id: UUID = UUID(), title: String, urlString: String, dateAdded: Date = Date()) {
        self.id = id
        self.title = title
        self.urlString = urlString
        self.dateAdded = dateAdded
    }
}


//
//  NewsModel.swift
//  NewsService
//
//  Created by Vinayaka Vasukeesha(UST,IN) on 04/03/25.
//

import Foundation

// MARK: - Response Models
struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable {
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String
    let content: String?
}

struct Source: Codable {
    let id: String?
    let name: String
}

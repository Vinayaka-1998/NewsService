//
//  APIConstants.swift
//  NewsService
//
//  Created by Vinayaka Vasukeesha(UST,IN) on 04/03/25.
//

enum APIConstants {
    static let baseURL = "https://newsapi.org/v2"
    static var apiKey = ""
    
    enum Endpoints {
        static let topHeadlines = "/top-headlines"
    }
    
    enum Parameters {
        static let apiKey = "apiKey"
        static let country = "country"
        static let sources = "sources"
    }
}

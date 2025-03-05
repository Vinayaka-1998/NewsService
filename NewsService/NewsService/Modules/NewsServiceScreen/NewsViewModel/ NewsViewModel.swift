//
//  NewsViewModel.swift
//  NewsService
//
//  Created by Vinayaka Vasukeesha(UST,IN) on 04/03/25.
//
import Foundation
import UIKit

// MARK: - ViewModel Protocol
protocol NewsViewModelProtocol {
    var articles: [Article] { get }
    var onArticlesUpdated: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var isLoading: Bool { get }
    var onLoadingStateChanged: ((Bool) -> Void)? { get set }
    
    func fetchTopHeadlinesByCountry(country: String)
    func fetchTopHeadlinesBySource(source: String)
    func loadImageWithNetworkFirstCaching(from urlString: String, completion: @escaping (UIImage?) -> Void)
}

// MARK: - View Model
class NewsViewModel: NewsViewModelProtocol {
    
    private let newsAPI: NewsAPIProtocol
    // Optional: Cached image loading method
    private var imageCache = NSCache<NSString, UIImage>()
    
    
    // MARK: - Properties
    private(set) var articles: [Article] = [] {
        didSet {
            onArticlesUpdated?()
        }
    }
    
    var groupedArticles: [String: [Article]] {
        Dictionary(grouping: articles, by: { $0.source.name })
    }
    
    private(set) var isLoading: Bool = false {
        didSet {
            onLoadingStateChanged?(isLoading)
        }
    }
    
    // MARK: - Callbacks
    var onArticlesUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    
    // MARK: - Initialization
    init(newsAPI: NewsAPIProtocol = NewsAPI()) {
        self.newsAPI = newsAPI
    }
    
    // MARK: - Methods
    func fetchTopHeadlinesByCountry(country: String) {
        isLoading = true
        
        newsAPI.getTopHeadlines(country: country) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    self.articles = response.articles
                    print("Fetched \(response.articles.count) articles from \(country)")
                    
                case .failure(let error):
                    self.onError?(error.description)
                }
            }
        }
    }
    
    func fetchTopHeadlinesBySource(source: String) {
        isLoading = true
        
        newsAPI.getTopHeadlinesBySource(source: source) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    self.articles = response.articles
                    print("Fetched \(response.articles.count) articles from \(source)")
                    
                case .failure(let error):
                    self.onError?(error.description)
                }
            }
        }
    }
}
extension NewsViewModel {
    
    // MARK: - Advanced Image Loading Method
    func loadImageWithNetworkFirstCaching(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        // Check if image is already in cache
        if let cachedImage = self.imageCache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }
        
        // Ensure we have a valid URL
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        // Create a URLSession data task to fetch the image
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for successful data retrieval
            guard
                let data = data,
                let image = UIImage(data: data),
                error == nil
            else {
                // If image loading fails, return nil
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Cache the image
            self.imageCache.setObject(image, forKey: urlString as NSString)
            
            // Return the image on the main queue
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
    
    // Optional method to pre-warm cache for known URLs
    func preWarmImageCache(urls: [String]) {
        urls.forEach { urlString in
            // Only attempt to load if not already in cache
            if self.imageCache.object(forKey: urlString as NSString) == nil {
                loadImageWithNetworkFirstCaching(from: urlString) { _ in }
            }
        }
    }
}

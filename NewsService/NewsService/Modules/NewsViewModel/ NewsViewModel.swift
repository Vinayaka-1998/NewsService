//
//  NewsViewModel.swift
//  NewsService
//
//  Created by Vinayaka Vasukeesha(UST,IN) on 04/03/25.
//
import Foundation

// MARK: - ViewModel Protocol
protocol NewsViewModelProtocol {
    var articles: [Article] { get }
    var onArticlesUpdated: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var isLoading: Bool { get }
    var onLoadingStateChanged: ((Bool) -> Void)? { get set }
    
    func fetchTopHeadlinesByCountry(country: String)
    func fetchTopHeadlinesBySource(source: String)
}

// MARK: - View Model
class NewsViewModel: NewsViewModelProtocol {
    
    private let newsAPI: NewsAPIProtocol
    
    
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

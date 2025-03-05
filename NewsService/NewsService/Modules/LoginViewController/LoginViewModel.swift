//
//  LoginViewModel.swift
//  NewsService
//
//  Created by Vinayaka Vasukeesha(UST,IN) on 04/03/25.
//

import Foundation
import UIKit

// MARK: - Login View Model Protocol
protocol LoginViewModelProtocol {
    var onLoginSuccess: (() -> Void)? { get set }
    var onLoginFailure: ((String) -> Void)? { get set }
    
    func validateAndLogin(name: String?, apiKey: String?)
}

class LoginViewModel: LoginViewModelProtocol {
    private let newsAPI: NewsAPIProtocol
    
    // Callbacks
    var onLoginSuccess: (() -> Void)?
    var onLoginFailure: ((String) -> Void)?
    
    init(newsAPI: NewsAPIProtocol = NewsAPI()) {
        self.newsAPI = newsAPI
    }
    
    func validateAndLogin(name: String?, apiKey: String?) {
        // Validate inputs
        guard let name = name, !name.isEmpty else {
            onLoginFailure?("Please enter your name")
            return
        }
        
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            onLoginFailure?("Please enter your API key")
            return
        }
    }
    
    func fetchTopHeadlinesByCountry(country: String) {
        newsAPI.getTopHeadlines(country: country) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.onLoginSuccess?()
                case .failure(let error):
                    self.onLoginFailure?(error.description)
                }
            }
        }
    }
}

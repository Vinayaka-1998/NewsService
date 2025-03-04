//
//  NetworkService.swift
//  NewsService
//
//  Created by Vinayaka Vasukeesha(UST,IN) on 04/03/25.
//

import Foundation
import UIKit

// MARK: - NetworkError
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case unknown(Error)
    
    var description: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from the server"
        case .decodingError:
            return "Error decoding response"
        case .serverError(let code):
            return "Server error with status code: \(code)"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

// MARK: - NewsAPI Protocol
protocol NewsAPIProtocol {
    func getTopHeadlines(country: String, completion: @escaping (Result<NewsResponse, NetworkError>) -> Void)
    func getTopHeadlinesBySource(source: String, completion: @escaping (Result<NewsResponse, NetworkError>) -> Void)
}

// MARK: - Network Manager
class NetworkManager {
    static let shared = NetworkManager()
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config)
    }
    
    func request<T: Decodable>(url: URL, completion: @escaping (Result<T, NetworkError>) -> Void) {
        let task = session.dataTask(with: url) { data, response, error in
            // Handle error
            if let error = error {
                completion(.failure(.unknown(error)))
                return
            }
            
            // Check HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noData))
                return
            }
            
            // Check status code
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.serverError(httpResponse.statusCode)))
                return
            }
            
            // Check if data exists
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            // Decode data
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingError))
            }
        }
        
        task.resume()
    }
}

// MARK: - NewsAPI Implementation
class NewsAPI: NewsAPIProtocol {
    private let networkManager = NetworkManager.shared
    
    func getTopHeadlines(country: String, completion: @escaping (Result<NewsResponse, NetworkError>) -> Void) {
        var components = URLComponents(string: APIConstants.baseURL + APIConstants.Endpoints.topHeadlines)
        
        components?.queryItems = [
            URLQueryItem(name: APIConstants.Parameters.country, value: country),
            URLQueryItem(name: APIConstants.Parameters.apiKey, value: APIConstants.apiKey)
        ]
        
        guard let url = components?.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        networkManager.request(url: url, completion: completion)
    }
    
    func getTopHeadlinesBySource(source: String, completion: @escaping (Result<NewsResponse, NetworkError>) -> Void) {
        var components = URLComponents(string: APIConstants.baseURL + APIConstants.Endpoints.topHeadlines)
        
        components?.queryItems = [
            URLQueryItem(name: APIConstants.Parameters.sources, value: source),
            URLQueryItem(name: APIConstants.Parameters.apiKey, value: APIConstants.apiKey)
        ]
        
        guard let url = components?.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        networkManager.request(url: url, completion: completion)
    }
}

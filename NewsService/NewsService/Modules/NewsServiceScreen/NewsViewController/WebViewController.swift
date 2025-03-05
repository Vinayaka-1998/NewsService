//
//  WebViewController.swift
//  NewsService
//
//  Created by Vinayaka Vasukeesha(UST,IN) on 04/03/25.
//


import UIKit
import WebKit

class WebViewController: UIViewController {
    // MARK: - UI Components
    private let webView: WKWebView = {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.tintColor = .systemBlue
        return progressView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Properties
    private var urlString: String
    private var progressObserver: NSKeyValueObservation?
    
    // MARK: - Initialization
    init(urlString: String) {
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.urlString = ""
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWebView()
        loadWebPage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        progressObserver?.invalidate()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Add webView
        view.addSubview(webView)

        // Add progressView
        view.addSubview(progressView)

        // Add activity indicator
        view.addSubview(activityIndicator)

        // Add close button
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        closeButton.tintColor = .label // Default system color
        closeButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)

        // Apply constraints
        NSLayoutConstraint.activate([
            // Close button constraints
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),

            // Progress view constraints (start content from 40px down)
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // WebView constraints
            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Activity indicator constraints
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // Dismiss function
    @objc private func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }

    
    private func setupWebView() {
        webView.navigationDelegate = self
        
        // Observe loading progress
        progressObserver = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            self?.progressView.progress = Float(webView.estimatedProgress)
            
            // Hide progress bar when loading is complete
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                    self?.progressView.alpha = 0
                }, completion: { _ in
                    self?.progressView.progress = 0
                })
            } else {
                self?.progressView.alpha = 1.0
            }
        }
    }
    
    // MARK: - Web Loading
    private func loadWebPage() {
        guard let url = URL(string: urlString) else {
            showError(message: "Invalid URL")
            return
        }
        
        activityIndicator.startAnimating()
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        // Update title to show URL domain
        if let host = url.host {
            title = host
        }
    }
    
    @objc private func refreshWebPage() {
        webView.reload()
    }
    
    // MARK: - Error Handling
    private func showError(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - WKNavigation Delegate
extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        
        // Update title with page title if available
        if let title = webView.title, !title.isEmpty {
            self.title = title
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        showError(message: error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        showError(message: error.localizedDescription)
    }
}

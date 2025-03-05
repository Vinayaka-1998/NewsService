//
//  NewsDetailViewController.swift
//  NewsService
//
//  Created by Vinayaka Vasukeesha(UST,IN) on 04/03/25.
//

import UIKit

class NewsDetailViewController: UIViewController {
    
    // MARK: - UI Components
    
    var source: String = ""
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: "NewsCell")
        return tableView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Properties
    private var viewModel: NewsViewModelProtocol
    
    // MARK: - Initialization
    init(viewModel: NewsViewModelProtocol = NewsViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = NewsViewModel()
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.fetchTopHeadlinesBySource(source: source)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add and layout title label
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // Add and layout table view
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Configure table view
        tableView.dataSource = self
        tableView.delegate = self
        
        // Add and layout activity indicator
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Add a refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    func fetchDertaisOfSource(source: String, sourceName: String) {
        self.source = source
        self.titleLabel.text = sourceName
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        // Update UI when articles are fetched
        viewModel.onArticlesUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
        
        // Handle errors
        viewModel.onError = { [weak self] errorMessage in
            self?.showError(message: errorMessage)
        }
        
        // Handle loading state
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            if isLoading {
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
                self?.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    // MARK: - Actions
    @objc private func refreshData() {
        // Refresh with current data source (you could store the current source in the ViewModel)
        viewModel.fetchTopHeadlinesByCountry(country: "us")
    }
    
    // Switch to a different news source.
    func switchToSource(source: String) {
        viewModel.fetchTopHeadlinesBySource(source: source)
    }
    
    // MARK: - Navigation
    private func openWebPage(for article: String) {
        
        let webViewController = WebViewController(urlString: article)
        self.present(webViewController, animated: true)
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

// MARK: - UITableView DataSource
extension NewsDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as? NewsTableViewCell else {
            return UITableViewCell()
        }
        
        let article = viewModel.articles[indexPath.row]
        cell.configure(with: article)
        viewModel.loadImageWithNetworkFirstCaching(from: article.urlToImage ?? "") { image in
            cell.newsImageView.image = image ?? UIImage(systemName: "newspaper")
        }
        cell.delegate = self
        
        return cell
    }
}

// MARK: - UITableView Delegate
extension NewsDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension NewsDetailViewController: UrlTappedProtocol {
    func onUrlTapped(url: String) {
        openWebPage(for: url)
    }
}

//
//  NewsCell.swift
//  NewsService
//
//  Created by Vinayaka Vasukeesha(UST,IN) on 04/03/25.
//

import UIKit

protocol UrlTappedProtocol: AnyObject {
    func onUrlTapped(url: String)
}


class NewsTableViewCell: UITableViewCell {
    // MARK: - UI Components
    weak var delegate: UrlTappedProtocol?
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.2
        view.layer.masksToBounds = false
        return view
    }()
    
        let newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 4
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.numberOfLines = 0
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    private let urlLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .systemBlue
        label.text = "Read more >"
        label.isUserInteractionEnabled = true
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Properties
    var onUrlTapped: (() -> Void)?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    // MARK: - UI Setup
    private func setupCell() {
        // Remove direct subview additions and add containerView
        contentView.addSubview(containerView)
        
        // Add subviews to containerView
        containerView.addSubview(newsImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(authorLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(urlLabel)
        
        // Add tap gesture for URL label
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(urlLabelTapped))
        urlLabel.addGestureRecognizer(tapGesture)
        
        // Apply constraints
        NSLayoutConstraint.activate([
            // Container view constraints - 16 padding on all sides
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Image view constraints - square image on the left
            newsImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            newsImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            newsImageView.widthAnchor.constraint(equalToConstant: 70),
            newsImageView.heightAnchor.constraint(equalToConstant: 70),
            
            // Title label constraints
            titleLabel.leadingAnchor.constraint(equalTo: newsImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Author label constraints
            authorLabel.leadingAnchor.constraint(equalTo: newsImageView.trailingAnchor, constant: 12),
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            authorLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Description label constraints
            descriptionLabel.leadingAnchor.constraint(equalTo: newsImageView.trailingAnchor, constant: 12),
            descriptionLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 4),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // URL label constraints
            urlLabel.leadingAnchor.constraint(equalTo: newsImageView.trailingAnchor, constant: 12),
            urlLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 6),
            urlLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            urlLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12)
        ])
   }

    
    override func prepareForReuse() {
        super.prepareForReuse()
        newsImageView.image = nil
        titleLabel.text = nil
        authorLabel.text = nil
        descriptionLabel.text = nil
        onUrlTapped = nil
    }
    
    // MARK: - Actions
    @objc private func urlLabelTapped() {
        guard let urlString = urlLabel.text else { return }
        delegate?.onUrlTapped(url: urlString)
    }

    
    // MARK: - Configuration
    func configure(with article: Article) {
        titleLabel.text = article.title
        authorLabel.text = article.author ?? "Unknown Author"
        descriptionLabel.text = article.description ?? "No description available"
        urlLabel.text = article.url
    }
    
//    private func loadImage(from url: URL) {
//        // Simple image loading for demonstration
//        // In a real app, use a proper image loading library like Kingfisher or SDWebImage
//        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
//            guard let data = data, let image = UIImage(data: data) else {
//                DispatchQueue.main.async {
//                    self?.newsImageView.image = UIImage(systemName: "newspaper")
//                }
//                return
//            }
//            
//            DispatchQueue.main.async {
//                self?.newsImageView.image = image
//            }
//        }.resume()
//    }
}

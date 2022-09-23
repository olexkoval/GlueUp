//
//  MovieTableViewCell.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 17.09.2022.
//

import UIKit
import Combine

final class MovieTableViewCell: UITableViewCell {
  static let identifier = "MovieTableViewCell"
  
  var viewModel: MovieCellViewModel?
  
  private var bindings = Set<AnyCancellable>()
  private var subscription: AnyCancellable?
    
  private let movieTitleLabel = UILabel()
  private let movieImageView = UIImageView()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)
      setupSubviews()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    viewModel = nil
    movieImageView.image = nil
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func willAppear() {
    setUpViewModel()
    viewModel?.loadMoviePosterImage()
  }
  
  func didDisappear() {
    subscription?.cancel()
  }
    
  private func setupSubviews() {
    
    [movieTitleLabel, movieImageView].forEach {
      addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    movieImageView.contentMode = .scaleAspectFit
    NSLayoutConstraint.activate([
      movieImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.0),
      movieImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
      movieImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      movieImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 45.0),
      movieImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 30.0),
      movieTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      movieTitleLabel.leadingAnchor.constraint(equalTo: movieImageView.trailingAnchor, constant: 10.0),
      contentView.trailingAnchor.constraint(lessThanOrEqualTo: movieTitleLabel.trailingAnchor, constant: 10.0)
    ])
  }
  
  private func setUpViewModel() {
    movieTitleLabel.text = viewModel?.movieTitle
    
    subscription?.cancel()
    subscription = viewModel?.moviePosterPublisher
      .sink { _ in } receiveValue: { [weak self] image in
        DispatchQueue.main.async {
          if image.size != .zero {
            self?.movieImageView.image = image
            self?.setNeedsLayout()
          }
        }
      }
    subscription?.store(in: &bindings)
  }
}

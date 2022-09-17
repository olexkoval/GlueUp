//
//  MovieTableViewCell.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 17.09.2022.
//

import UIKit


final class MovieTableViewCell: UITableViewCell {
  static let identifier = "MovieTableViewCell"
  
  var viewModel: MovieCellViewModel? {
    didSet { setUpViewModel() }
  }
  
  private let movieTitleLabel: UILabel
  private let descriptionLabel: UILabel
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    movieTitleLabel = UILabel()
    descriptionLabel = UILabel()
    
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    addSubiews()
    setUpConstraints()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    viewModel = nil
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func addSubiews() {
    [movieTitleLabel, descriptionLabel].forEach {
      contentView.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
  }
  
  private func setUpConstraints() {
    NSLayoutConstraint.activate([
      movieTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: C.paddingOffset),
      movieTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: C.paddingOffset),
      movieTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -C.paddingOffset),
      
      descriptionLabel.centerYAnchor.constraint(equalTo: movieTitleLabel.centerYAnchor),
      descriptionLabel.leadingAnchor.constraint(equalTo: movieTitleLabel.trailingAnchor, constant: C.paddingOffset),
      descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -C.paddingOffset),
      descriptionLabel.heightAnchor.constraint(equalTo: movieTitleLabel.heightAnchor)
    ])
  }
  
  private func setUpViewModel() {
    movieTitleLabel.text = viewModel?.movieTitle ?? ""
    descriptionLabel.text = viewModel?.movieDescription ?? ""
  }
}

private extension MovieTableViewCell {
  struct C {
    static let paddingOffset: CGFloat = 10.0
  }
}

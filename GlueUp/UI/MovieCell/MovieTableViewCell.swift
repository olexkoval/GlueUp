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
  
  var viewModel: MovieCellViewModel? {
    didSet { setUpViewModel() }
  }
  
  private var bindings = Set<AnyCancellable>()
  private var subscription: AnyCancellable?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    viewModel = nil
    imageView?.image = nil
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func willAppear() {
    viewModel?.loadMoviePosterImage()
  }
  
  func didDisappear() {
    subscription?.cancel()
  }
  
  private func setUpViewModel() {
    textLabel?.text = viewModel?.movieTitle
    
    subscription?.cancel()
    subscription = viewModel?.moviePosterPublisher
      .receive(on: RunLoop.main)
      .sink { _ in } receiveValue: { [weak self] image in
        if image.size != .zero {
          self?.imageView?.image = image
          self?.setNeedsLayout()
        }
      }
    subscription?.store(in: &bindings)
  }
}

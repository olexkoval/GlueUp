//
//  MovieDetailsViewController.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 17.09.2022.
//

import UIKit
import Combine

class MovieDetailsViewController: UIViewController {
  private let viewModel: MovieDetailsViewModel
  private weak var navigationCoordinator: NavigationCoordinator?
  
  private var bindings = Set<AnyCancellable>()

  private lazy var idLabel = UILabel()
  private lazy var titleLabel = UILabel()
  private lazy var voteCountLabel = UILabel()
  private lazy var releaseDateLabel = UILabel()
  private lazy var overviewLabel = UILabel()
  private lazy var imageView: UIImageView = UIImageView()

  init(viewModel: MovieDetailsViewModel, navigationCoordinator: NavigationCoordinator) {
    self.viewModel = viewModel
    self.navigationCoordinator = navigationCoordinator
    
    super.init(nibName: nil, bundle: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    setupSubviews()
    setupConstraints()
    bindModelView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if imageView.image == nil {
      viewModel.loadMoviePosterImage()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      
      navigationCoordinator?.movingBack()
  }
  
  private func setupSubviews() {
    [idLabel, titleLabel, voteCountLabel, releaseDateLabel, overviewLabel, imageView].forEach {
      view.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
    overviewLabel.numberOfLines = 0
  }
  
  private func setupConstraints() {
    let salg = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: salg.topAnchor, constant: C.paddingOffset),
      titleLabel.centerXAnchor.constraint(equalTo: salg.centerXAnchor),
      
      imageView.centerXAnchor.constraint(equalTo: salg.centerXAnchor),
      imageView.bottomAnchor.constraint(equalTo: salg.centerYAnchor),
      imageView.leadingAnchor.constraint(greaterThanOrEqualTo: salg.leadingAnchor, constant: C.paddingOffset),
      imageView.heightAnchor.constraint(lessThanOrEqualToConstant: C.imageMaxHeight),
      
      releaseDateLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: C.paddingOffset),
      releaseDateLabel.centerXAnchor.constraint(equalTo: salg.centerXAnchor),
      
      idLabel.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: C.paddingOffset),
      idLabel.centerXAnchor.constraint(equalTo: salg.centerXAnchor),
      
      voteCountLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: C.paddingOffset),
      voteCountLabel.centerXAnchor.constraint(equalTo: salg.centerXAnchor),
      
      overviewLabel.topAnchor.constraint(equalTo: voteCountLabel.bottomAnchor, constant: C.paddingOffset),
      overviewLabel.centerXAnchor.constraint(equalTo: salg.centerXAnchor),
      overviewLabel.bottomAnchor.constraint(greaterThanOrEqualTo: salg.bottomAnchor, constant: -C.paddingOffset),
      overviewLabel.leadingAnchor.constraint(greaterThanOrEqualTo: salg.leadingAnchor, constant: C.paddingOffset)
    ])
    
  }
  
  private func bindModelView() {
    
    viewModel.moviePosterPublisher
      .receive(on: RunLoop.main)
      .sink{ _ in } receiveValue: { [weak self] _ in
        self?.imageView.image = self?.viewModel.moviePosterImage
      }
      .store(in: &bindings)
    
    idLabel.text = viewModel.id
    titleLabel.text = viewModel.title
    voteCountLabel.text = viewModel.voteCount
    releaseDateLabel.text = viewModel.releaseDate
    overviewLabel.text = viewModel.overview
  }
}

private extension MovieDetailsViewController {
  struct C {
    static let paddingOffset: CGFloat = 10.0
    static let imageMaxHeight: CGFloat = 300.0

  }
}


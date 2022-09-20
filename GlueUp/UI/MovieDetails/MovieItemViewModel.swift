//
//  MovieItemViewModel.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 20.09.2022.
//

import UIKit
import Combine

protocol MovieItemViewModel {
  var id: String { get }
  var title: String { get }
  var voteCount: String { get }
  var releaseDate: String { get }
  var overview: String { get }
  var moviePosterImage: UIImage { get }
  
  func loadMoviePosterImage()
  
  var moviePosterPublisher: Published<UIImage>.Publisher { get }
}

class MovieItemViewModelImpl {
  
  @Published private(set) var moviePosterImage: UIImage = UIImage()
  
  private let movie: MovieItemDTO
  private let moviePosterLoader: MoviePosterLoader
  private var bindings = Set<AnyCancellable>()
  
  init(movie: MovieItemDTO, moviePosterLoader: MoviePosterLoader) {
    self.movie = movie
    self.moviePosterLoader = moviePosterLoader
  }
  
  var id: String { "\(movie.id)" }
  
  var title: String { movie.title }
  
  var voteCount: String { "\(movie.voteCount)" }
  
  var releaseDate: String { DateFormatter.sting(movie.releaseDate) }
  
  var overview: String { movie.overview }
}

extension MovieItemViewModelImpl: MovieItemViewModel {
  
  var moviePosterPublisher: Published<UIImage>.Publisher { $moviePosterImage }
  
  func loadMoviePosterImage() {
    moviePosterLoader.loadMoviePosterImage(movie: movie)
      .sink { [weak self] completion in
        switch completion {
        case .finished:
          break
        case.failure:
          self?.moviePosterImage = UIImage(named: "themoviedb") ?? UIImage()
        }
      } receiveValue: { [weak self] image in
        self?.moviePosterImage = image
      }.store(in: &bindings)
  }
}

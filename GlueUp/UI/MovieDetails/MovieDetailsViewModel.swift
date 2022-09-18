//
//  MovieDetailsViewModel.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 17.09.2022.
//

import Foundation

protocol MovieDetailsViewModel {
  
}

final class MovieDetailsViewModelImpl {
  
  private let movie: MovieItemDTO
  
  init(movie: MovieItemDTO) {
    self.movie = movie
  }
}

extension MovieDetailsViewModelImpl: MovieDetailsViewModel {
  
}

//
//  MovieCellViewModel.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 17.09.2022.
//

import Foundation
import Combine

final class MovieCellViewModel {
  let movieTitle: String
  let movieDescription: String
  
  private let movie: MovieItemDTO
  
  init(movie: MovieItemDTO) {
    
    self.movie = movie
    
    movieDescription = "Release date: \(DateFormatter.sting(movie.releaseDate)) Votes: \(movie.voteCount)"
    movieTitle = movie.title
  }
}
